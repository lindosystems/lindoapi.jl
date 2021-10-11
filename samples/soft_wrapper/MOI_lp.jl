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
#
#               2 <= x1 <= 5
#               1 <= x2 <= +inf
#            -inf <= x3 <= 10
#            -inf <= x4 <= +inf

using Lindoapi
using LinearAlgebra
using MathOptInterface
using Printf
const MOI  = MathOptInterface

OPTIMIZER = Lindoapi.Optimizer()

c = [1.0, 1.0, 1.0, 1.0]

w1 = [3.0, 0.0, 0.0, 2.0]
w2 = [0.0, 6.0, 0.0, 9.0]
w3 = [4.0, 5.0, 8.0, 0.0]
w4 = [0.0, 7.0, 1.0, 0.0]

b1 = 20.0
b2 = 20.0
b3 = 40.0
b4 = 10.0

x = MOI.add_variables(OPTIMIZER,4)

MOI.add_constraint(OPTIMIZER, MOI.SingleVariable(x[1]), MOI.Interval(2.0,5.0))
MOI.add_constraint(OPTIMIZER, MOI.SingleVariable(x[2]), MOI.Interval(1.0,typemax(Float64)))
MOI.add_constraint(OPTIMIZER, MOI.SingleVariable(x[3]), MOI.Interval(-typemax(Float64),10.0))
MOI.add_constraint(OPTIMIZER, MOI.SingleVariable(x[4]), MOI.Interval(-typemax(Float64),typemax(Float64)))

MOI.set(
OPTIMIZER,
MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}(),
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0.0),
)

f_1 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w1, x), 0.0),
MOI.EqualTo(b1),
)

f_2 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w2, x), 0.0),
MOI.GreaterThan(b2),
)

f_3 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w3, x), 0.0),
MOI.EqualTo(b3),
)

f_4 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w4, x), 0.0),
MOI.GreaterThan(b4),
)

MOI.optimize!(OPTIMIZER)
dObj = MOI.get(OPTIMIZER, MOI.ObjectiveValue())
primal = MOI.get(OPTIMIZER, MOI.VariablePrimal())

#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%s  %20s\n" "Index" "Primal Value"
println(repeat('=', 30))
for i in 1:4
    @printf "%i %20.5f \n" i primal[i]
end
println()
