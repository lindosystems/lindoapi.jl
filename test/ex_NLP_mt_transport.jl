"""
Nonlinear Integer Programing Transportation Models

Minimize:
Total cost of transportation

Subject to:
Demand is at least met
Supply can not be exseeded
Flow from a Supply node to a Demand node must be positive

Each model bellow will have a diffrent transportation cost function, and
will share the same constraints.

Model 1) Flat rate sum(x[i,j])









"""


using Lindoapi
using JuMP
using Printf
using Base.Threads



n = 3
m = 5

source = [10,12,15,18,16]
sink = [25,26,20]


#decline rate of shiping
f = [
     1 0.15 1.6
     2 1.1 1.2
     0.6 0.7 1
     0.5 0.9 1.1
     1 1.6 1
]

# threshold
g = [
     4 2 3
     5 2 2
     2 2 3
     2 3 2
     5 3 4
]

a = [
    1 1.5 1.6
    2 1.1 1.2
    0.6 0.7 1
    0.5 0.9 1.1
    1 1.6 1
]
b = [
    30 27 28.5
    36 28.8 39
    24 27 25.5
    23.4 33 30
    36 31.5 33
]

function transport_model()

        model = Model(Lindoapi.Optimizer)
        @variable(model, x[1:m,1:n], Int)
        for i in 1:m, j in 1:n
                @NLconstraint(model, x[i,j] >= 0)
        end

        for i in 1:m
                @NLconstraint(model, sum(x[i,j] for j in 1:n) >= source[i])
        end

        for j in 1:n
                @NLconstraint(model, sum(x[i,j] for i in 1:m) <= sink[j])
        end
        return model, x

end

function flat_rate()
    model, x = transport_model()
    @NLobjective(model, Min, sum( x[i,j] for i in 1:m, j in 1:n))
    optimize!(model)
    return model, x
end

function linear_rate_incress()
        model, x = transport_model()
        @NLobjective(model, Min,
                     sum(x[i,j]*(b[i,j] + a[i,j]*x[i,j])
                          for i in 1:m, j in 1:n
                        )
                      )
        optimize!(model)
        return model, x
end

function linear_rate_break()
        model, x = transport_model()
        @NLobjective(model, Min, sum(
                                     x[i,j]*(b[i,j] - a[i,j]*x[i,j])
                                     for i in 1:m, j in 1:n
                                     )
                     )

        optimize!(model)
        return model, x
end

function exponetial_rate_incress()
        #decline rate of shiping
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*exp(f[i,j]*(x[i,j]-g[i,j])) for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end

function exponetial_rate_break()
        model, x = transport_model()
        @NLobjective(model, Min, sum(x[i,j]*exp(-1*f[i,j]*(x[i,j]-g[i,j])) for i in 1:m, j in 1:n))
        optimize!(model)
        return model, x
end


model, x = flat_rate()

models = [flat_rate(), linear_rate_incress(), linear_rate_break(), exponetial_rate_incress(), exponetial_rate_break()]

@threads for i in 1:length(models)
    models[i]
end

println("Model 1) flat rate")
println("Model 2) linear rate incress")
println("Model 3) linear rate break")
println("Model 4) exponetial rate incress")
println("Model 5) exponetial rate break")
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
