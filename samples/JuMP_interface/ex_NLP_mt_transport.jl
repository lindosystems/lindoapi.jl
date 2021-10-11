
"""
Lindoapi JuMP Interface multiple model example.

Nonlinear Integer Programing Transportation Models

Minimize:
Total cost of transportation

Subject to:
Demand (D) is at least met                                       ∑_{i ∈ 1:m} x_{ij} ≧ Dⱼ ∀ j ∈ 1:n
Supply (K) cannot be exceeded                                    ∑_{j ∈ 1:n} x_{ij} ≦ Kᵢ ∀ i ∈ 1:m
Flow from a Supply node to a Demand node must be positive        x_{ij} ≧ 0 ∀ i,j

Each model bellow will have a different transportation cost function, and
will share the same constraints.

Model 1) flat rate  ``c_{i,j} = 1 ∀ i,j``

         This model is a Linear Integer Transportation problem
         that seeks to minimize a unit transpiration cost.

Model 2) linear rate increase  ``c_{i,j} = b_{i,j} + a_{i,j}x_{i,j}``

        In this model as shipping to a destination increases
        the cost of shipping increases linearly.

Model 3) linear rate break ``c_{i,j} = b_{i,j} - a_{i,j}x_{i,j}``

        In this model the transportation cost decreases linearly
        as the volume of shipping increases.


Model 4) exponential rate increase ``c_{i,j} = exp{f_{i,j}(x_{i,j} - g_{i,j})}``

        In this model as shipping cost increases exponentially when
        shipping to from supply node i to demand node j exceeds the
        threshold g_{i,j}.

Model 5) exponential rate break ``c_{i,j} = exp{-f_{i,j}(x_{i,j} - g_{i,j})}``

        In this model as shipping cost decreases exponentially when
        shipping to from supply node i to demand node j exceeds the
        threshold g_{i,j}.
"""

using Lindoapi
using JuMP
using Printf
using Base.Threads

supply = [10,12,15,18,16]
demand = [25,26,20]
m = length(supply)
n = length(demand)

# exponetial models rate increase
f = [
     1 0.15 1.6
     2 1.1 1.2
     0.6 0.7 1
     0.5 0.9 1.1
     1 1.6 1
]

# exponetial models shipping threshold
g = [
     4 2 3
     5 2 2
     2 2 3
     2 3 2
     5 3 4
]

# linear models rate increase
a = [
    1 1.5 1.6
    2 1.1 1.2
    0.6 0.7 1
    0.5 0.9 1.1
    1 1.6 1
]

# linear models rate threshold
b = [
    30 27 28.5
    36 28.8 39
    24 27 25.5
    23.4 33 30
    36 31.5 33
]

#=
This function creates a model declares the variables and
adds the transportation constraints
=#
function transport_model()

        model = Model(Lindoapi.Optimizer)
        @variable(model, x[1:m,1:n] >= 0, Int)

        for i in 1:m
                @NLconstraint(model, sum(x[i,j] for j in 1:n) <= supply[i])
        end

        for j in 1:n
                @NLconstraint(model, sum(x[i,j] for i in 1:m) >= demand[j])
        end
        return model, x

end

#=

flat_rate(), linear_rate_increase(), linear_rate_break(), exponetial_rate_increase(), exponetial_rate_break()

All call transport_model()

Then declare thier associated objective function

Finaly calls optimize!(model)
returning the model and matrix of variables

=#
function flat_rate()
    model, x = transport_model()
    @NLobjective(model, Min, sum( x[i,j] for i in 1:m, j in 1:n))
    optimize!(model)
    return model, x
end

function linear_rate_increase()
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*(b[i,j] + a[i,j]*x[i,j])
                                     for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end

function linear_rate_break()
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*(b[i,j] - a[i,j]*x[i,j])
                                     for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end

function exponetial_rate_increase()
        #decline rate of shiping
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*exp(f[i,j]*(x[i,j]-g[i,j]))
                                     for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end

function exponetial_rate_break()
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*exp(-1*f[i,j]*(x[i,j]-g[i,j]))
                                     for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end


models = [flat_rate(), linear_rate_increase(), linear_rate_break(), exponetial_rate_increase(), exponetial_rate_break()]

#=
This loop uses @threads to assign each model in the list models
to a cpu thread to be solved
=#
@threads for i in 1:length(models)
    models[i]
end

#=
Display the results
=#
println("Model 1) flat rate                ",  termination_status(models[1][1]))
println("Model 2) linear rate increase     ",  termination_status(models[2][1]))
println("Model 3) linear rate break        ",  termination_status(models[3][1]))
println("Model 4) exponetial rate increase ",  termination_status(models[4][1]))
println("Model 5) exponetial rate break    ",  termination_status(models[5][1]))
println("=====================================")
println("Model   1    2    3    4    5")
println("S->D")
println("-------------------------------------")
for i in 1:m, j in 1:n
        @printf("%d->%d  |", i,j)
        for k in 1:length(models)
        @printf("%4d |", value((models[k][2])[i,j]))
        end
        print("\n-------------------------------------\n")
end
        println()
