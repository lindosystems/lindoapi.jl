"""
A Julia programming example of interfacing with LINDO API Using JuMP.
See path_to_samples/soft_wrapper/lp.jl for the same model using
the soft wrapper

  The problem:

      Minimize x1 + x2 + x3 + x4 + x5 + x6
      s.t.
               [r1]- x1 - x2 - x3 - x4 - x5 - x6    <=3;
               [r2]  x1 + x2                        <=1;
               [r3]       x2 + x3                   <=1;
               [r4]                 x4 + x5 + x6    <=2;
               [r5]                 x4 +      x6    <=1;

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

A = [-1 -1 -1 -1 -1 -1
     1 1 0 0 0 0
     0 1 1 0 0 0
     0 0 0 1 1 1
     0 0 0 1 0 1]
b = [-3
     1
     1
     2
     1]

mCons, nVars = size(A)

# Create a model
model = Model(Lindoapi.Optimizer)

# Creating a vector of binary variables
@variable(model, x[1:nVars], Bin)

# Make all the constraints
@constraint(model, A*x .<= b)

# Set the objective function
@objective(model, Min, sum(x[i] for i in 1:nVars))

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

#=
Startpoint info (not feasible):
  Objvalue                         : 6.000000e+00  (startpoint)
  Infeasibility of solution        : 1.0e+00
  Integer infeasibility of solution: 0.0e+00


MIP solution with integers rounded to the nearest integer (useOpti:1)
 Status (R)      = 12
 Objective (R)   = 6.000000
 Primal inf. (R) = 1.00e+00
MIP Solver | Iter:0, Obj=3
Feasible obj value found in MIP prerelax heu=3.000000
Ori. size (m, n, nz,  nip):      5,      6,       15,       6


Number of constraints:       3    le:       3, ge:       0, eq:       0, rn:       0 (ne:0)
Number of variables  :       4    lb:       0, ub:       0, fr:       0, bx:       4 (fx:0)
Number of nonzeroes  :       8    density:  0.0067(%)     , sb:       0, dir:min

Abs. Ranges     :         Min.          Max.    Condition.
Matrix Coef. (A):      1.00000       1.00000       1.00000
Obj. Vector  (c):      1.00000       1.00000       1.00000
RHS Vector   (b):      1.00000       2.00000       2.00000
Lower Bounds (l):  1.0000e-100   1.0000e-100       1.00000
Upper Bounds (u):      1.00000       1.00000       1.00000
BadScale Measure: 0

Binary variables     :       4 (in 3 constraints)
Integer variables    :       0 (in 0 constraints)
New  size (m, n, nz,  nip):      3,      4,        8,       4

Time Consumed in probing: 0.01 (sec.)


MIP Solver | Iter:0, Obj=3

#BRANCHs  #NODEs    #LPs    BEST BOUND      BEST  IP     RGAP    TIME  OPTIME
(CUTPASS) (NUMCUT)            (SUMFP)                                   (CODE)

        0      0        0  -1.000000e+30   3.000000e+00 1.0e+00  0.00  (*K)
        0      0        0   3.000000e+00   3.000000e+00 0.0e+00  0.00  0.00  (99.99opt)

Optimum found

Status                       :                      1
Objective Value              :                      3
Best Bound                   :                      3
Rel. MIP Gap                 :           0.000000e+00
Abs. MIP Gap                 :           0.000000e+00

Primal Infeasibility         :           0.000000e+00
Integer Infeasibility        :           0.000000e+00

Total Branches               :                      0
Total LPs Solved             :                      0
Simplex Iterations           :                      0
Barrier Iterations           :                      0
Nonlinear Iterations         :                      0
Cutting planes applied       :                      0 (0)
Total Time (sec.)            :                      0


Objective is: 3
Variable      Value
=====================
x[1]         1.00000 
x[2]         0.00000
x[3]         0.00000
x[4]         1.00000
x[5]         1.00000
x[6]         0.00000
=#