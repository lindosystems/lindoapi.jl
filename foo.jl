"""

  A Julia programming example of interfacing with LINDO API.

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


To update to the most current version of Lindoapi.jl
 Run in REPL:
    using Pkg
    Pkg.add(url="https://github.com/lindosystems/Lindoapi.jl")


"""

using Lindoapi
using JuMP
using Printf


nCons = 4
nVars = 4

model = Model(Lindoapi.Optimizer)

x = @variables(model,
    begin
    2 <= x1 <= 100
    1 <= x2 <= 100
    0    <= x3
    0    <= x4
     end
)

@NLconstraint(model, c1, 3*x1 + x2 + x3 + 2*x4  == 20)

@NLobjective(model, Max, x1 + x2 + x3 + x4)

optimize!(model)

obj_val = objective_value(model)

x1_star = value(x1)
x2_star = value(x2)
x3_star = value(x3)
x4_star = value(x4)

x1_rd   = reduced_cost(x1)
# x2_rd   = reduced_cost(x2)
# x3_rd   = reduced_cost(x3)
# x4_rd   = reduced_cost(x4)
#
# slacks = [1,1,1,1]#get_optimizer_attribute(model,Lindoapi.Slack_or_Surplus())
#
# c1_dual = dual(c1)
# c2_dual = dual(c2)
# c3_dual = dual(c3)
# c4_dual = dual(c4)
#
# @printf("Objective is: %.10f \n", obj_val)
# println("Variable      Value        Reduced Cost")
# println("========================================")
# @printf("x[1] %15.5f %15.5f \n", x1_star, x1_rd)
# @printf("x[2] %15.5f %15.5f \n", x2_star, x2_rd)
# @printf("x[3] %15.5f %15.5f \n", x3_star, x3_rd)
# @printf("x[4] %15.5f %15.5f \n", x4_star, x4_rd)
#
# println()
# println("Row      Slack or Surplus   Dual Price")
# println("========================================")
# @printf("c[1] %15.5f %15.5f \n", slacks[1], c1_dual)
# @printf("c[2] %15.5f %15.5f \n", slacks[2], c2_dual)
# @printf("c[3] %15.5f %15.5f \n", slacks[3], c3_dual)
# @printf("c[4] %15.5f %15.5f \n", slacks[4], c4_dual)
