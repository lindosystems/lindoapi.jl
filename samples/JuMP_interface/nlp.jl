"""

  A Julia programming example of interfacing with LINDO API Using JuMP.
  See path_to_samples/soft_wrapper/lp.jl for the same model using
  the soft wrapper.

        minimize  f(x,y) =  3*(1-x)^2*exp(-(x^2) - (y+1)^2)
                         - 10*(x/5 - x^3 - y^5)*exp(-(x^2)-y^2)
                         - 1/3*exp(-((x+1)^2) - y^2);
        subject to
                         x^2 + y   <=  6;
                         x   + y^2 <=  6;
                         x, y unconstrained in sign;

 To run sample
     include("/PathToUse/JuMP_interface/nlp.jl")

 To update to the most current version of Lindoapi.jl
      Run in REPL:
          using Pkg
          Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")
"""

using Lindoapi
using JuMP
using Printf
const LS = Lindoapi
# Set to true to use
# the global solver
use_Global = false
uDict = Dict(
"Prefix" => "Lindo API Callback",
"Postfix" => "...",)

# This callback function calls LSgetCallbackInfo to get information
# to printout.
# LS_IINFO_NLP_ITER: number of non linear iterations
# LS_DINFO_POBJ    : Primal objective value
# LS_DINFO_DINFEAS : Maximum primal infeasibility
function cbFunc(pModel, nLocation, uData)
    nlp_itter    = Int32[-1]
    obj_val      = Cdouble[-1]
    infeasibilty = Cdouble[-1]

    LS.LSgetCallbackInfo(pModel, nLocation, LS.LS_IINFO_NLP_ITER, nlp_itter)
    LS.LSgetCallbackInfo(pModel, nLocation, LS.LS_DINFO_POBJ    , obj_val)
    LS.LSgetCallbackInfo(pModel, nLocation, LS.LS_DINFO_DINFEAS , infeasibilty)

    println(uData["Prefix"])
    @printf("NLP iteration   : %d\n"   ,  nlp_itter[1])
    @printf("Objective value : %.10f\n",  obj_val[1])
    @printf("Infeasibilty    : %.6f\n" ,  infeasibilty[1])
    println(uData["Postfix"])
    println()
end


# Create a model
model = Model(Lindoapi.Optimizer)
MOI.set(model, Lindoapi.CallbackFunction(uDict), cbFunc)

# Turn on global solver if use_GLoabal == true
set_optimizer_attribute(model,"use_Global", use_Global)

# Creating the two variables
@variable(model, x)
@variable(model, y)

# Objective function
@NLobjective(model, Min,
              3*(1-x)^2*exp(-x^2 - (y+1)^2)
            - 10*(x/5 - x^3 - y^5)*exp(-x^2 - y^2)
            - 1/3*exp(-((x+1)^2) - y^2)
          )

# Model constraints
@constraint(model, x^2 + y   <=  6)
@constraint(model, x   + y^2 <=  6)

# Call the optimizer
optimize!(model)

# retruve the results
obj_val = objective_value(model)
x_star  = value(x)
y_star  = value(y)

println()
@printf("Objective is: %.5f \n",obj_val)
@printf("%10s\n", "Primal")
println(repeat('=', 30))
@printf("x %10.5f\n", x_star)
@printf("y %10.5f\n", y_star)
println()


#=

# Output with use_Global = false

NLP local optimizer started.

  Iter  Phase   nInf         Objective    Pinf(sum)  Dinf(rgmax)      Time
     0      0      0   1.00000000e+030   1.000e+000   0.000e+000      0.00
    10      3      0   1.32849228e-001   0.000e+000   0.000e+000      0.00

NLP local optimizer terminated, obj:0.132849, pfeas:1.38645e-012, status:8 (err: 0).



Used Method        = 7
Used Time          = 0
Refactors (ok,stb) = 0 (-1.#J,-1.#J)
Simplex   Iters    = 0
Barrier   Iters    = 0
Nonlinear Iters    = 10
Primal Status      = 8
Dual   Status      = 12
Basis  Status      = 14
Primal Objective   = 0.13284922819442171
Dual   Objective   = 0.13284922819442171
Duality Gap        = 0.000000e+000
Primal Infeas      = 1.386447e-012
Dual   Infeas      = 0.000000e+000


Solution is locally optimal.

Objective is: 0.13285
    Primal
==============================
x    2.00000
y    2.00000



# Output with use_Global = true

Start LSsolveGOP


Number of constraints:       2    le:       2, ge:       0, eq:       0, rn:       0 (ne:0)
Number of variables  :       2    lb:       0, ub:       0, fr:       2, bx:       0 (fx:0)
Number of nonzeroes  :       4    density:    0.01(%)     , sb:       0, dir:min

Abs. Ranges     :         Min.          Max.    Condition.
Matrix Coef. (A):      1.00000       1.00000       1.00000
Obj. Vector  (c):  1.0000e-100   1.0000e-100       1.00000
RHS Vector   (b):  1.0000e-100   1.0000e-100       1.00000
Lower Bounds (l):  1.0000e-100   1.0000e-100       1.00000
Upper Bounds (u):  1.0000e+030   1.0000e+030       1.00000
BadScale Measure: 0

Nonlinear variables  :       2
Nonlinear constraints:       3
Nonlinear nonzeroes  :       2+2

Starting global optimization ...

Number of Threads: 1

Number of nonlinear functions/operators:  3
 EP_MULTIPLY  EP_POWER  EP_EXP

Starting GOP presolve ...
First Call Local Solver

Global Solver | Iter:0, Obj=0.132849Find local solution, objvalue =     0.132849

Computing reduced bound...
Searching for a better solution...

Starting Main Loop...

Global Solver | Iter:248, Obj=-0.0649359

 #NODEs  BOXES   LOWER BOUND     UPPER BOUND      RGAP   TIME(s)

     1       0  -2.706339e+003  -6.493587e-002  1.0e+000      0 (*N)

Global Solver | Iter:792, Obj=-6.55113     4       3  -2.268329e+003  -6.551133e+000  1.0e+000      7 (*N)
   100      29  -6.566295e+000  -6.551133e+000  2.3e-003      8
   200      31  -6.551844e+000  -6.551133e+000  1.1e-004      8
   251      26  -6.551295e+000  -6.551133e+000  2.5e-005      8 (*I)
   255      22  -6.551274e+000  -6.551133e+000  2.1e-005      8 (*I)
   262      21  -6.551247e+000  -6.551133e+000  1.7e-005      8 (*I)
   280       9  -6.551218e+000  -6.551133e+000  1.3e-005      8 (*I)
   291       0  -6.551180e+000  -6.551133e+000  7.2e-006      9 (*F)


Terminating global search ...



 Global optimum found
 Objective value              :         -6.55113333284
 Best Bound                   :         -6.55118042507
 Rel. GOP Gap                 :          7.188359e-006
 Abs. GOP Gap                 :          4.709224e-005
 Factors (ok,stb)             :                   2571 (100.00,100.00)
 Simplex iterations           :                  14169
 Barrier iterations           :                      0
 Nonlinear iterations         :                   1451
 Box iterations               :                    291
 Total number of boxes        :                    291
 Max. Depth                   :                     42
 First solution time (sec.)   :                      0
 Best solution time (sec.)    :                      7
 Total time (sec.)            :                      9



Objective is: -6.55113
    Primal
==============================
x    0.22828
y   -1.62553

=#
