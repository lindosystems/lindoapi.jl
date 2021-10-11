#   JuMP NLP Exsample
#
#   To download the API
#   julia> using Pkg
#   julia> Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")
#
#   To Run
#   julia> include("/PathToUse/jump_exsample.jl")
#
#   For more detail see
#   https://github.com/lindosystems/lindoapi.jl
#   https://jump.dev/JuMP.jl/stable/
#
#        minimize  f(x,y) =  3*(1-x)^2*exp(-(x^2) - (y+1)^2)
#                         - 10*(x/5 - x^3 - y^5)*exp(-(x^2)-y^2)
#                         - 1/3*exp(-((x+1)^2) - y^2);
#        subject to
#                         x^2 + y   <=  6;
#                         x   + y^2 <=  6;
#                         x, y unconstrained in sign;


using Lindoapi
using JuMP
using Printf


model = Model(Lindoapi.Optimizer)
n = 2
@variable(model, x[1:n])

@NLconstraint(model, x[1]^2 + x[2]   <=  6)
@NLconstraint(model, x[1] + x[2]^2 <=  6)
@NLobjective(model, Min,
3*(1-x[1])^2 * exp( -1*(x[1]^2)) - 10*(x[1]/5 - x[1]^3 - x[2]^5)
* exp(-1*(x[1]^2)-x[2]^2) - 1/3*exp(-1*((x[1]+1)^2) - x[2]^2)
)

optimize!(model)

#
objVal = objective_value(model)
dualObjVal = dual_objective_value(model)
#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective Value :  %.7f \n" objVal
@printf "Dual Value      :  %.7f \n\n" dualObjVal
@printf "%s  %20s\n" "Index" "Primal Value"
println(repeat('=', 30))
for i in 1:n
    @printf "%i %20.6f \n" i value(x[i])
end
println()
