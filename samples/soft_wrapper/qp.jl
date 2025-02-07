"""

    A Julia programming example of interfacing with LINDO API using
    the soft wrapper. See path_to_samples/JuMP_interface/lp.jl
    for the same model using the JuMP interface.

 Set up and solve a (quadratic) portfolio model with LINDO API.

                    Portfolio Selection Problem
                       The Markowitz Model.

       MAXIMIZE  r(1)w(1) + ... +r(n)w(n)
           st.       sum_{ij} Q(i,j)w(i)w(j) <= K
                         w(1) + ..... + w(n)  = 1
                         w(1),         ,w(n) >= 0
           where
           r(i)  : return on asset i
           Q(i,j): covariance between the returns of i^th and
                   j^th assets.
           K     : a scalar denoting the level of risk of loss.
           w(i)  : proportion of total budget invested on asset i

           Covariance Matrix:
                  w1    w2    w3    w4
             w1 [ 1.00  0.64  0.27  0.    ]
             w2 [ 0.64  1.00  0.13  0.    ]
             w3 [ 0.27  0.13  1.00  0.    ]
             w4 [ 0.    0.    0.    1.00  ]

           Returns Vector:
                    w1    w2    w3    w4
           r =   [ 0.30  0.20 -0.40  0.20  ]

           Risk of Loss Factor:
           K = 0.4

To run sample
   include("/PathToUse/soft_wrapper/qp.jl")

To update to the most current version of LindoAPI.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/LindoAPI.jl")

"""

import LindoAPI
using Printf
const LS = LindoAPI
PATH = ENV["LINDOAPI_HOME"]

uDict = Dict()                                                                  # Empty Dict

function logFunc(pModel, line, uDict)                                           # A simple log callback function
  @printf "%s" line
end

# LP data
nCons = 2
nAssets = 4
K = 0.40
objsense = LS.LS_MAX
objconst = 0
reward = Cdouble[0.300,0.200,-0.400,0.200]
rhs = Cdouble[K/2,1.0]
contype = UInt8['L','E']
Anz = 4
Abegcol = Int32[0,1,2,3,Anz]
Alencol = C_NULL
A = Cdouble[1.,1.,1.,1.]
Arowndx = Int32[1,1,1,1]
lb = C_NULL
ub = C_NULL


#QP data
Qnz = 7
Qrowndx  = Int32[0,0,0,0,0,0,0]
Qcolndx1 = Int32[0,0,0,1,1,2,3]
Qcolndx2 = Int32[0,1,2,1,2,2,3]
Q = Cdouble[1.0000,0.6400,0.2700,1.0000,0.1300,1.0000,1.0000]

# Get API key
LicenseKey = Vector{UInt8}(undef,1024)                                          # Allocating memory for a vector of 1024 UInt8
license_path = joinpath(PATH,"license/lndapi150.lic")                           # Creating a license path to where the key is
ret = LS.LSloadLicenseString(license_path, LicenseKey)                          # Now calling API function
if ret != 0
    error("Key not found check key $(license_path)")                            # Throwing an error if key not found
end

pnErrorCode = Int32[-1]                                                         # Int32[-1] this is making an array of one elemet
# Create Lindo environment and model objects                                    # of type Int32 the one element is -1
pEnv = LS.LScreateEnv(pnErrorCode, LicenseKey)                                  # pnErrorCode only element will be replace with error code
LS.check_error(pEnv,pnErrorCode[1])                                             # Checke the error code with LS.check_error

# Create model
pModel = LS.LScreateModel(pEnv, pnErrorCode)                                    # reusing pnErrorCode to hold error code
LS.check_error(pEnv,pnErrorCode[1])                                             # from last API call

# load data into the model
errorcode = LS.LSloadLPData(                                                    # From the above LP model data
                pModel, nCons, nAssets, objsense, objconst,
                reward, rhs, contype, Anz, Abegcol,
                Alencol, A, Arowndx,lb, ub
                )
LS.check_error(pEnv, errorcode)

#load QP data into the model
errorcode = LS.LSloadQCData(                                                    # From the above QP model data
                pModel, Qnz, Qrowndx,
                Qcolndx1, Qcolndx2, Q
                )
LS.check_error(pEnv,errorcode)

# Setting the log callback function
errorcode = LS.LSsetModelLogfunc(pModel, logFunc, uDict)                        # logFunc and uDict is defined above
LS.check_error(pEnv, errorcode)

# solve the model
pnStatus  = Int32[-1]                                                           # pnStatus will hold the termination status
errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_BARRIER, pnStatus)               # of the model
LS.check_error(pEnv,errorcode)                                                  # LS.LS_METHOD_BARRIER tells the solver to user
                                                                                # A Barrier method to optimize the model
if (pnStatus[1] == LS.LS_STATUS_OPTIMAL ||
    pnStatus[1] == LS.LS_STATUS_BASIC_OPTIMAL
    )

    # Retrieve the objective value
    obj_val   = Cdouble[-1]
    errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, obj_val)
    LS.check_error(pEnv, errorcode)

    # Retrieve the primal solution
    w_star    = Vector{Cdouble}(undef, nAssets)
    errorcode = LS.LSgetPrimalSolution(pModel, w_star)
    LS.check_error(pEnv, errorcode)

    # Reduced cost
    reducedCost = Vector{Cdouble}(undef, nAssets)
    errorcode   = LS.LSgetReducedCosts(pModel, reducedCost)
    LS.check_error(pEnv, errorcode)

    # Retrive Slacks
    slacks    = Vector{Cdouble}(undef, nCons)
    errorcode = LS.LSgetSlacks(pModel, slacks)
    LS.check_error(pEnv, errorcode)

    # comute the varince using the
    # diffrence between the Risk of Loss Factor and Slack
    variance = K - slacks[2]
    # Get Dual Prices
    duals     = Vector{Cdouble}(undef, nCons)
    errorcode = LS.LSgetDualSolution(pModel, duals)
    LS.check_error(pEnv, errorcode)
    # Printing out objective value and primal solution
    @printf("Expected Return: %.5f \n", obj_val[1])
    @printf("Variance       : %.5f \n", variance)
    println()
    println("Variable      Value        Reduced Cost")
    println("========================================")
    for i in 1:nAssets
        @printf("w[%d] %15.3f %13.3f \n", i, w_star[i], reducedCost[i])
    end
    println()
    println("    Row           Slack or Surplus   Dual Price")
    println("===============================================")
    @printf("risk_con      %15.3f %15.3f \n",
            slacks[1], duals[1])
    @printf("portfolio_con %15.3f %15.3f \n",
            slacks[2], duals[2])

end
#delete LINDO model pointer
errorcode = LS.LSdeleteModel(pModel)
LS.check_error(pEnv,errorcode)

#delete LINDO environment pointer
errorcode = LS.LSdeleteEnv(pEnv)
LS.check_error(pEnv,errorcode)

#=                       Output

tpre       ncons      nvars         nnzA      time
 ini           2          4            4      0.00
Problem
  Name                   : LindoAPI
  Objective sense        : max
  Type                   : QCQO (quadratically constrained optimization problem)
  Constraints            : 2
  Cones                  : 0
  Scalar variables       : 4
  Matrix variables       : 0
  Integer variables      : 0

Optimizer started.
Quadratic to conic reformulation started.
Quadratic to conic reformulation terminated. Time: 0.00
Presolve started.
Linear dependency checker started.
Linear dependency checker terminated.
Eliminator started.
Freed constraints in eliminator : 0
Eliminator terminated.
Eliminator - tries                  : 1                 time
    : 0.00
Lin. dep.  - tries                  : 1                 time
    : 0.00
Lin. dep.  - number                 : 0
Presolve terminated. Time: 0.00
Problem
  Name                   : LindoAPI
  Objective sense        : max
  Type                   : QCQO (quadratically constrained optimization problem)
  Constraints            : 2
  Cones                  : 0
  Scalar variables       : 4
  Matrix variables       : 0
  Integer variables      : 0

Optimizer  - threads                : 1
Optimizer  - solved problem         : the primal
Optimizer  - Constraints            : 3
Optimizer  - Cones                  : 1
Optimizer  - Scalar variables       : 8                 conic
    : 6
Optimizer  - Semi-definite variables: 0                 scalarized
    : 0
Factor     - setup time             : 0.00              dense det. time
    : 0.00
Factor     - ML order time          : 0.00              GP order time
    : 0.00
Factor     - nonzeros before factor : 6                 after factor
    : 6
Factor     - dense dim.             : 0                 flops
    : 6.20e+01
ITE PFEAS    DFEAS    GFEAS    PRSTATUS   POBJ              DOBJ
   MU       TIME
0   1.0e+00  4.0e-01  1.8e+00  0.00e+00   0.000000000e+00   8.485281374e-01   1.0e+00  0.00
1   2.9e-01  1.1e-01  1.1e-01  1.00e+00   1.762821689e-01   5.647364009e-01   2.9e-01  0.03
2   5.9e-02  2.4e-02  9.8e-03  1.45e+00   2.174871940e-01   2.810106360e-01   5.9e-02  0.03
3   2.3e-02  9.1e-03  3.8e-03  7.86e-01   1.855629208e-01   2.127780859e-01   2.3e-02  0.03
4   1.7e-03  6.9e-04  8.5e-05  9.81e-01   1.752181615e-01   1.772189240e-01   1.7e-03  0.03
5   7.3e-05  2.9e-05  7.8e-07  9.80e-01   1.732722789e-01   1.733548247e-01   7.3e-05  0.03
6   1.1e-06  4.5e-07  1.5e-09  9.95e-01   1.731623400e-01   1.731636052e-01   1.1e-06  0.03
7   1.0e-07  4.0e-08  4.0e-11  9.99e-01   1.731606553e-01   1.731607664e-01   1.0e-07  0.03
8   1.3e-08  5.3e-09  2.0e-12  1.00e+00   1.731605499e-01   1.731605645e-01   1.3e-08  0.03
9   6.8e-10  2.7e-10  2.3e-14  1.00e+00   1.731605384e-01   1.731605391e-01   6.8e-10  0.05
Optimizer terminated. Time: 0.06




Used Method        = 3
Used Time          = 0
Refactors (ok,stb) = 0 (-1.#J,-1.#J)
Simplex   Iters    = 0
Barrier   Iters    = 9
Nonlinear Iters    = 0
Primal Status      = 1
Dual   Status      = 1
Basis  Status      = 13
Primal Objective   = 0.17316053839304504
Dual   Objective   = 0.17315919994279916
Duality Gap        = 1.338450e-006
Primal Infeas      = 6.754126e-010
Dual   Infeas      = 2.701648e-010


Solution is optimal.
Expected Return: 0.17316
Variance       : 0.40000

Variable      Value        Reduced Cost
========================================
w[1]           0.281        -0.000
w[2]           0.218        -0.000
w[3]           0.092        -0.000
w[4]           0.410        -0.000

    Row           Slack or Surplus   Dual Price
===============================================
risk_con               -0.000           2.807
portfolio_con           0.000          -0.950

=#
