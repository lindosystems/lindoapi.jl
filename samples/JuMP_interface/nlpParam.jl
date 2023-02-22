#=

          MIN = 20*x*y*z - (x-y)^3;   --> f1(.)
          !SUBJECT TO;
               2*x*z + 3*x^2 <= 35;   --> f2(.)
               x*y*z + 2*y*z >= 10;   --> f3(.)
               x^2 + z^2 <= 23;       --> f4(.)
          !BOUNDS;
	          @BND(0,x,7);
	          @BND(0,y,7);
	          @BND(0,z,7);

=#

using Lindoapi
using JuMP

# optional multistart
bMultiStart = true
# number of multistarts
n_multistarts = 5

# Create a model
model = Model(Lindoapi.Optimizer)

# Creating the three variables
@variable(model, 0 <= x <= 7)
@variable(model, 0 <= y <= 7)
@variable(model, 0 <= z <= 7)

# Objective function
@NLobjective(model, Min, 20*x*y*z - (x-y)^3)

# Add Constraints
Con1 = @constraint(model, 2*x*z + 3*x^2 <= 35)
Con2 = @NLconstraint(model, x*y*z + 2*y*z >= 10)
Con3 = @constraint(model, x^2 + z^2 <= 23)

# Optionally, turn multi-start search on
if (bMultiStart)

    #uses CONOPT with multistart feature enabled. 
    LS_IPARAM_NLP_SOLVER = Lindoapi.LindoIntParam(Lindoapi.LS_IPARAM_NLP_SOLVER)
    JuMP.set_optimizer_attribute(model, LS_IPARAM_NLP_SOLVER, 9) 
    # set maximum number of multistarts
    LS_IPARAM_NLP_MAXLOCALSEARCH = Lindoapi.LindoIntParam(Lindoapi.LS_IPARAM_NLP_MAXLOCALSEARCH)
    JuMP.set_optimizer_attribute(model, LS_IPARAM_NLP_MAXLOCALSEARCH, n_multistarts) 

end


#solve
optimize!(model)