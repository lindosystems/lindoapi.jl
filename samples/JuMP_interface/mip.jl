"""
A Julia programming example of interfacing with LINDO API Using JuMP.
See path_to_samples/soft_wrapper/lp.jl for the same model using
the soft wrapper

  The problem:

      Minimize x1 + x2 + x3 + x4 + x5 + x6
      s.t.
               [r1]x1 + x2 + x3 + x4 + x5 + x6  >=3;
               [r2]x1 + x2                      <=1;
               [r3]     x2 + x3                 <=1;
               [r4]               x4 + x5 + x6  <=2;
               [r5]               x4 +      x6  <=1;

               x1,x2,x3,x4,x5,x6 are binary variables

To run sample
   include("/PathToUse/JuMP_interface/mip.jl")

To update to the most current version of Lindoapi.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")
"""

using Lindoapi
using JuMP
using Printf


nVars = 6

# Create a model
model = Model(Lindoapi.Optimizer)

# Creating a vector of binary variables
@variable(model, x[1:nVars], Bin)

# Make all the constraints
@NLconstraint(model, x[1] + x[2] + x[3] + x[4] + x[5] + x[6]  >= 3)
@NLconstraint(model, x[1] + x[2]                              <= 1)
@NLconstraint(model,        x[2] + x[3]                       <= 1)
@NLconstraint(model,                      x[4] + x[5] + x[6]  <= 2)
@NLconstraint(model,                      x[4] +        x[6]  <= 1)

# Set the objective function
@NLobjective(model, Min, sum(x[i] for i in 1:nVars))

# Call Optimizer
optimize!(model)

# Get results
obj_val = objective_value(model)
x_star  = value.(x)                                                             # use the `.` to broadcast over vector

@printf("Objective is: %d \n", obj_val)
println("Variable      Value")
println("=====================")
for i in 1:nVars
@printf("x[%d] %15.5f \n",i, x_star[i])
end
