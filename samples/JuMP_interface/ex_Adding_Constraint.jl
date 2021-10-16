"""
Adding A Constraint To Solved Model

minimize  f(x,y) =  3*(1-x)^2*exp(-(x^2) - (y+1)^2)
                - 10*(x/5 - x^3 - y^5)*exp(-(x^2)-y^2)
                - 1/3*exp(-((x+1)^2) - y^2);
subject to
                x^2 + y   <=  6;
                x   + y^2 <=  6;
                x, y unconstrained in sign;

After the the model is solved add the constraint
                    x   + y^2 <=  6;


To run sample
    include("/PathToUse/ex_Adding_Constraint.jl")

To update to the most current version of Lindoapi.jl
Run in REPL:
    using Pkg
    Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")

This sample also uses the libraries Printf
and is not added as dependencies when installing Lindoapi.jl
If not installed yet
Run in REPL:
    using Pkg
    Pkg.add("Printf")

"""

using Lindoapi
using JuMP
using Printf


model = Model(Lindoapi.Optimizer)

@variable(model, x)
@variable(model, y)
@NLconstraint(model, x^2 + y   <=  6)
@NLobjective(model,
             Min,
             3*(1-x)^2 * exp( -1*(x^2)) - 10*(x/5 - x^3 - y^5)
                 * exp(-1*(x^2)-y^2) - 1/3*exp(-1*((x+1)^2) - y^2)
            )

optimize!(model)
objVal1 = objective_value(model)
x1 = value(x)
y1 = value(y)


@NLconstraint(model, x + y^2   <=  6)
optimize!(model)
objVal2 = objective_value(model)
x2 = value(x)
y2 = value(y)

#=
    Printing out objective value and primal solution
=#
println()

@printf("Objective Value 1:  %.7f \n", objVal1)
@printf("Objective Value 2:  %.7f \n", objVal2)
@printf("  %15s %10s\n",  "x", "y")
println(repeat('=', 35))

@printf("First  run: %10.6f %10.6f\n", x1, y1)
@printf("Second run: %10.6f %10.6f\n", x2, y2)
