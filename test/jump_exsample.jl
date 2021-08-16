#  A Julia programming example of interfacing with LINDO API.
#
#  The problem:
#
#      Minimize x1 + x2 + x3 + x4
#      s.t.
#              3x1              + 2x4   = 20
#                    6x2        + 9x4  >= 20
#              4x1 + 5x2 + 8x3          = 40
#                    7x2 + 1x3         >= 10

using Lindoapi
using JuMP

c = [1.0, 1.0, 1.0, 1.0]

w1 = [3.0, 0.0, 0.0, 2.0]
w2 = [0.0, 6.0, 0.0, 9.0]
w3 = [4.0, 5.0, 8.0, 0.0]
w4 = [0.0, 7.0, 1.0, 0.0]

b1 = 20.0
b2 = 20.0
b3 = 40.0
b4 = 10.0

model = Model(Lindoapi.Optimizer)
n = length(c)
@variable(model, x[1:n])

f_1 = @constraint(model, x'w1 == b1)
f_2 = @constraint(model, x'w2 >= b2)
f_3 = @constraint(model, x'w3 == b3)
f_4 = @constraint(model, x'w4 >= b4)

@objective(model, Min, x'c)

optimize!(model)
#
objVal = objective_value(model)

#=
    Printing out objective value and primal solution
=#
# println()
# @printf "Objective is: %.5f \n" objVal
# @printf "%s  %20s\n" "Index" "Primal Value"
# println(repeat('=', 30))
# for i in 1:n
#     @printf "%i %20.5f \n" i value(x[i])
# end
# println()
