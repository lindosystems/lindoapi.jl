"""

  A Julia programming example of interfacing with LINDO API using
  the soft wrapper. See path_to_samples/JuMP_interface/lp.jl
  for the same model using the JuMP interface.

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
    include("/PathToUse/soft_wrapper/lp.jl")

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

# Model data
nCons = 4
nVars = 4
objsense = LS.LS_MIN
dObjConst = 0.0
adC = Cdouble[1.0,1.0,1.0,1.0]                                                  # See the API Manual page 13 for
adB = Cdouble[20.0,20.0,40.0,10.0]                                              # Array Representation of Models
acConTypes = UInt8['E','G','E','G']                                             # In Julia putting datatype in front of arryay
nNZ =  9                                                                        # will ensure its type
anBegCol = Int32[0,2,5,7,9]
pnLenCol = C_NULL
adA = Cdouble[3.0,4.0,6.0,5.0,7.0,8.0,1.0,2.0,9.0]
anRowX = Int32[0,2,1,2,3,2,3,0,1]
pdLower = Cdouble[2,1,-(LS.LS_INFINITY), -(LS.LS_INFINITY)]
pdUpper = Cdouble[5,LS.LS_INFINITY, 10, LS.LS_INFINITY]

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
errorcode = LS.LSloadLPData(                                                    # From the above model data
                pModel,nCons,nVars,objsense,
                dObjConst,adC,adB,acConTypes,nNZ,anBegCol,
                pnLenCol,adA,anRowX,pdLower,pdUpper
                )
LS.check_error(pEnv, errorcode)

# Setting the log callback function
errorcode = LS.LSsetModelLogfunc(pModel, logFunc, uDict)                        # logFunc and uDict is defined above
LS.check_error(pEnv, errorcode)

# Solve the model
pnStatus = Int32[-1]
errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_FREE, pnStatus)                  # pnStatus will hold the termination status
LS.check_error(pEnv, errorcode)                                                 # of the model

if (pnStatus[1] == LS.LS_STATUS_OPTIMAL ||                                      # print results only if optimal
    pnStatus[1] == LS.LS_STATUS_BASIC_OPTIMAL)

    # Retrieve the objective value
    dObj = Cdouble[-1]
    errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, dObj)
    LS.check_error(pEnv, errorcode)

    # Retrieve the primal solution
    padPrimal = Vector{Cdouble}(undef, nVars)                                   # Allocate enough atleast the number
    errorcode = LS.LSgetPrimalSolution(pModel, padPrimal)                       # of variables in the model.
    LS.check_error(pEnv, errorcode)

    # Reduced cost
    reducedCost = Vector{Cdouble}(undef, nVars)
    errorcode = LS.LSgetReducedCosts(pModel, reducedCost)
    LS.check_error(pEnv, errorcode)

    # Retrive Slacks
    slacks = Vector{Cdouble}(undef, nCons)                                      # Allocate enough atleast the number
    errorcode = LS.LSgetSlacks(pModel, slacks)                                  # of constraints in the model.
    LS.check_error(pEnv, errorcode)

    # Get Dual Prices
    duals = Vector{Cdouble}(undef, nCons)
    errorcode = LS.LSgetDualSolution(pModel, duals)
    LS.check_error(pEnv, errorcode)

    # Printing out objective value and primal solution
    println()
    @printf "Objective is: %.5f \n" dObj[1]
    println("Variable      Value        Reduced Cost")
    println("========================================")
    for i in 1:nVars
        @printf "x[%d] %15.5f %15.5f \n" i padPrimal[i] reducedCost[i]
    end
    println()

    println("Row      Slack or Surplus   Dual Price")
    println("========================================")
    for i in 1:nCons
        @printf "c[%d] %15.5f %15.5f \n" i slacks[i] duals[i]
    end

else
   @printf("Optimal solution was not found -- status: %d\n", pnStatus[1])
end

 # Delete LINDO model pointer
 errorcode = LS.LSdeleteModel(pModel)
 LS.check_error(pEnv, errorcode)

 # Delete LINDO environment pointer
 errorcode = LS.LSdeleteEnv(pEnv)
 LS.check_error(pEnv, errorcode)




#=                  Output
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

Objective is: 10.44118
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
