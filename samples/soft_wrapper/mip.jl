"""
    A Julia programming example of interfacing with LINDO API using
    the soft wrapper. See path_to_samples/JuMP_interface/lp.jl
    for the same model using the JuMP interface.

  The problem:

      Minimize x1 + x2 + x3 + x4 + x5 + x6
      s.t.
               [r1]x1 + x2 + x3 + x4 + x5 + x6  >=3;
               [r2]x1 + x2                      <=1;
               [r3]     x2 + x3                 <=1;
               [r4]               x4 + x5 + x6  <=2;
               [r5]               x4 +      x6  <=1;

               x1,x2,x3,x4,x5,x6 are binary variables

To run sample
   include("/PathToUse/soft_wrapper/mip.jl")

To update to the most current version of LindoAPI.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/LindoAPI.jl")
"""

import LindoAPI
using Printf
const LS = LindoAPI
PATH = ENV["LINDOAPI_HOME"]

uDict = Dict(                                                                   # A dictionary to hold passthrough data
"Prefix" => "Lindo API",
"Postfix" => "...",)

function logFunc(pModel, line, uDict)                                           # A simple log callback function
  @printf "%s" line
end

function cbMIPFunc(pModel, uDict, dObj, padPrimal)                              # A simple MIP Callback function
    dIter = Cdouble[-1.0]
    errorcode = LS.LSgetProgressInfo(pModel, 0, LS.LS_DINFO_CUR_ITER, dIter)
    @printf "\ncbMIPFunc | Iter:%g, Obj=%g"  dIter[1] dObj
end

#model data
nCons = 5
nVars = 6
nDir = 1
dObjConst = 0.0                                                                 # See the API Manual page 13 for
adC = Cdouble[1.,1.,1.,1.,1.,1.]                                                # Array Representation of Models
adB = Cdouble[3.0,1.0,1.0,2.0,1.0]                                              # In Julia putting datatype in front of arryay
acConTypes = UInt8['G','L','L','L','L']                                         # will ensure its type
nNZ = 15
anBegCol = Int32[0,2,5,7,10,12,15]
pnLenCol = C_NULL
adA = Cdouble[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
anRowX = Int32[0,1,0,1,2,0,2,0,3,4,0,3,0,3,4]
pdLower = Cdouble[0,0,0,0,0,0]
pdUpper = Cdouble[1.,1.,1.,1.,1.,1.]
pachVarType = Cchar['B','B','B','B','B','B']

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

#load data into the model
errorcode = LS.LSloadLPData(
               pModel,nCons,nVars,nDir,                                         # From the above model data
               dObjConst,adC,adB,acConTypes,nNZ,anBegCol,
               pnLenCol,adA,anRowX,pdLower,pdUpper
               )
LS.check_error(pEnv,pnErrorCode[1])

# Setting the log callback function
errorcode = LS.LSsetModelLogfunc(pModel, logFunc, uDict)                        # logFunc and uDIct is defined above
LS.check_error(pEnv, errorcode)

# Setting the MIP callback function
errorcode = LS.LSsetMIPCallback(pModel, cbMIPFunc, uDict)                       # cbMIPFunct is a user defined function
LS.check_error(pEnv, errorcode)                                                 # From above

#solve the model
pnStatus = Int32[-1]                                                            # pnStatus will hold the termination status
errorcode = LS.LSsolveMIP(pModel, pnStatus)                                     # of the model
LS.check_error(pEnv, errorcode)

#retrieve the objective value
dObj = Cdouble[-1]
errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_MIP_OBJ, dObj)
LS.check_error(pEnv, errorcode)

padPrimal = Vector{Cdouble}(undef, nVars)                                       # Allocate enough atleast the number
errorcode = LS.LSgetMIPPrimalSolution(pModel, padPrimal)                        # of variables in the model.
LS.check_error(pEnv, errorcode)

# Printing out objective value and primal solution
println()
@printf("Objective is: %d \n", dObj[1])
println("Variable      Value")
println("=====================")
for i in 1:nVars
@printf("x[%d] %15.5f \n",i, padPrimal[i])
end

#delete LINDO model pointer
errorcode = LS.LSdeleteModel(pModel)
LS.check_error(pEnv, errorcode)

#delete LINDO environment pointer
errorcode = LS.LSdeleteEnv(pEnv)
LS.check_error(pEnv, errorcode)


#=
cbMIPFunc | Iter:0, Obj=3
Feasible obj value found in MIP prerelax heu=3.000000
Ori. size (m, n, nz,  nip):      5,      6,       15,
 6


Number of constraints:       3    le:       2, ge:       1, eq:       0, rn:       0 (ne:0)
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
New  size (m, n, nz,  nip):      3,      4,        8,
 4

Time Consumed in probing: 0.04 (sec.)


cbMIPFunc | Iter:0, Obj=3

#BRANCHs  #NODEs    #LPs    BEST BOUND      BEST  IP     RGAP    TIME  OPTIME
(CUTPASS) (NUMCUT)            (SUMFP)
             (CODE)

        0      0        0  -1.000000e+30   3.000000e+00 1.0e+00  0.04  (*K)
        0      0        0   3.000000e+00   3.000000e+00 0.0e+00  0.04  0.00  (99.96opt)

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
Total Time (sec.)            :                   0.04



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
