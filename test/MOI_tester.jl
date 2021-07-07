using LINDO
using LinearAlgebra
using MathOptInterface

const MOI  = MathOptInterface

OPTIMIZER = LINDO.Optimizer()
c = [2.0, 1.0]

w1 = [1.0, 1.0]
w2 = [1.0, -1.0]


b1 = 6.0
b2 = 4.0


x = MOI.add_variables(OPTIMIZER,2)

MOI.set(
OPTIMIZER,
MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}(),
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0.0),
)

f_1 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w1, x), 0.0),
MOI.GreaterThan(b1),
)

f_2 = MOI.add_constraint(
OPTIMIZER,
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w2, x), 0.0),
MOI.GreaterThan(b2),
)

MOI.set(
OPTIMIZER,
MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}(),
MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0.0),
)

OPTIMIZER.objective_sense = MOI.MAX_SENSE

MOI.optimize!(OPTIMIZER)

# MOI.optimize!(OPTIMIZER)

####################################################
# Not working yet
#MOIT.contlineartest(BRIDGED_OPTIMIZER, CONFIG)

#=
                    Output
    [ Info: Loading License ---> LSloadLicenseString
    [ Info: Creating Enviroment ---> LScreateEnv
    ┌ Info: MOIB.LazyBridgeOptimizer{Optimizer}
    │ with 0 variable bridges
    │ with 0 constraint bridges
    │ with 0 objective bridges
    └ with inner model Lindo API with the pointer Ptr{Nothing} @0x00007f83e9d8b800
    ┌ Info: Testing Variable Creation ===>
    └   MOI.add_variables(OPTIMIZER, 10) = 0
    ┌ Info: MOIB.LazyBridgeOptimizer{Optimizer}
    │ with 0 variable bridges
    │ with 0 constraint bridges
    │ with 0 objective bridges
    └ with inner model Lindo API with the pointer Ptr{Nothing} @0x00007f83e9d8b800
=#

#=
max c'x
st w'x <= C
c = [1.0, 2.0, 3.0]
w = [0.3, 0.5, 1.0]
optimizer = Optimizer()
x = MOI.add_variables(optimizer, length(c));
MOI.set(
           optimizer,
           MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}(),
           MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0.0),
       );
MOI.set(optimizer, MOI.ObjectiveSense(), MOI.MAX_SENSE)
MOI.add_constraint(
           optimizer,
           MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w, x), 0.0),
           MOI.LessThan(C),
       );
for x_i in x
    MOI.add_constraint(optimizer, MOI.SingleVariable(x_i), MOI.ZeroOne())
end
MOI.optimize!(optimizer)
MOI.get(optimizer, MOI.TerminationStatus())
=#
