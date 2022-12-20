"""

  A Julia programming example of interfacing with LINDO API Using JuMP.
  See path_to_samples/soft_wrapper/lp.jl for the same model using
  the soft wrapper.

  The problem:

      Minimize x1 + x2 + x3 + x4
      s.t.
              3x1              + 2x4   = 20
                    6x2        + 9x4  >= 20
              4x1 + 5x2 + 8x3          = 40
                    7x2 + 1x3         >= 10

               2 <= x1 <= 5
               1 <= x2 <= +inf
            -inf <= x3 <= 10
            -inf <= x4 <= +inf

To run sample
    include("/PathToUse/JuMP_interface/lp.jl")

To update to the most current version of Lindoapi.jl
 Run in REPL:
    using Pkg
    Pkg.add(url="https://github.com/lindosystems/Lindoapi.jl")


"""

using Lindoapi
using JuMP
using Printf

nCons = 4                                                                       # Number of constraints and variables
nVars = 4
cons = Vector{ConstraintRef}(undef, nCons)                                      # This vactor is to hold the constraints
                                                                                # ConstraintRef is the datatype

# Create a model
model = Model(Lindoapi.Optimizer)

# Creating variables and bounds
@variables(model,
    begin
    2 <= x1 <= 5
    1 <= x2
         x3 <= 10
         x4
     end
)

# Next the constraints
cons[1] = @constraint(model, 3*x1               + 2*x4  == 20)
cons[2] = @constraint(model,        6*x2        + 9*x4  >= 20)
cons[3] = @constraint(model, 4*x1 + 5*x2 + 8*x3         == 40)
cons[4] = @constraint(model,        7*x2 +   x3         >= 10)

# Objective function
@objective(model, Min, x1 + x2 + x3 + x4)

# Call Optimizer
optimize!(model)

# Print out results if optimal
if termination_status(model) == MOI.OPTIMAL

    obj_val = objective_value(model)                                            # all_variables(model) returns a vector
    x_star  = value.(all_variables(model))                                      # of all variables attached to model
    x_rd    = reduced_cost.(all_variables(model))                               # use the `.` to broadcast over vector
    slacks  = get_optimizer_attribute(model,Lindoapi.Slack_or_Surplus())
    duals   = dual.(cons)

    @printf("Objective is: %.5f \n", obj_val)
    println("Variable      Value        Reduced Cost")
    println("========================================")
    for i in 1:nVars
    @printf("x[i] %15.5f %15.5f \n", x_star[i], x_rd[i])
    end

    println("Row      Slack or Surplus   Dual Price")
    println("========================================")
    for i in 1:nCons
        @printf "c[%d] %15.5f %15.5f \n" i slacks[i] duals[i]
    end

else
    println("Optimal solution was not found -- status: ", raw_status(model))
end


#=
tpre       ncons      nvars         nnzA      time
 ini           4          6           11      0.00
 sp1           3          5            9      0.00
 sp1           2          4            6      0.00
 eli           1          3            3      0.00
 sp1           0          0            0      0.00



Used Method        = -1
Used Time          = 0
Refactors (ok,stb) = 0 (-1.#J,-1.#J)
Simplex   Iters    = 0
Barrier   Iters    = 0
Nonlinear Iters    = 0
Primal Status      = 2
Dual   Status      = 2
Basis  Status      = 2
Primal Objective   = 10.441176470588236
Dual   Objective   = 10.441176470588236
Duality Gap        = 0.000000e+000
Primal Infeas      = 1.776357e-015
Dual   Infeas      = 1.387779e-017


Basic solution is optimal.
Objective is: 10.4411764706
Variable      Value        Reduced Cost
========================================
x[1]         5.00000        -0.97059
x[2]         1.17647         0.00000
x[3]         1.76471         0.00000
x[4]         2.50000         0.00000

Row      Slack or Surplus   Dual Price
========================================
c[1]         0.00000         0.50000
c[2]        -9.55882        -0.00000
c[3]         0.00000         0.11765
c[4]        -0.00000         0.05882
=#
