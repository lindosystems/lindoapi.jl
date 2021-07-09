#  Solve an MIP model.
#
#  The problem:
#
#      Minimize x1 + x2 + x3 + x4 + x5 + x6
#      s.t.
#               [r1]x1 + x2 + x3 + x4 + x5 + x6  >=3;
#               [r2]x1 + x2                      <=1;
#               [r3]     x2 + x3                 <=1;
#               [r4]               x4 + x5 + x6  <=2;
#               [r5]               x4 +      x6  <=1;
#
#               x1,x2,x3,x4,x5,x6 are binary variables
import LINDO
using Printf
const LS = LINDO
PATH = ENV["LINDOAPI_HOME"]

uDict = Dict(
"Prefix" => "Lindo API",
"Postfix" => "...",)

function logFunc(pModel, line, uDict)
  @printf "%s" line
end

function cbMIPFunc(pModel, uDict, dObj, padPrimal)
    dIter = Cdouble[-1.0]
    errorcode = LS.LSgetProgressInfo(pModel, 0, LS.LS_DINFO_CUR_ITER, dIter)
    @printf "\ncbMIPFunc | Iter:%g, Obj=%g"  dIter[1] dObj
end

#model data
nCons = 5
nVars = 6
nDir = 1
dObjConst = 0.0
adC = Cdouble[1.,1.,1.,1.,1.,1.]
adB = Cdouble[3.0,1.0,1.0,2.0,1.0]
acConTypes = UInt8['G','L','L','L','L']
nNZ = 15
anBegCol = Int32[0,2,5,7,10,12,15]
pnLenCol = C_NULL
adA = Cdouble[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
anRowX = Int32[0,1,0,1,2,0,2,0,3,4,0,3,0,3,4]
pdLower = Cdouble[0,0,0,0,0,0]
pdUpper = Cdouble[1.,1.,1.,1.,1.,1.]
pachVarType = Cchar['B','B','B','B','B','B']

# create Lindo enviroment and model objects
LicenseKey = Vector{UInt8}(undef,1024)
license_path = joinpath(PATH,"license/lndapi130.lic")
@info "Loading License ---> calling LSloadLicenseString"
ret = LS.LSloadLicenseString(license_path, LicenseKey)
if ret != 0
    error("Key not found check key $(license_path)")
end
pnErrorCode = Int32[-1]
@info "Creating Enviroment ---> calling LScreateEnv"
pEnv = LS.LScreateEnv(pnErrorCode, LicenseKey)
LS.check_error(pEnv,pnErrorCode[1])

# create model
@info "Creating Model ---> calling LScreateModel"
pModel = LS.LScreateModel(pEnv, pnErrorCode)
LS.check_error(pEnv,pnErrorCode[1])

#load data into the model
@info "Loading LP data into model ---> calling LSloadLPData"
errorcode = LS.LSloadLPData(pModel,nCons,nVars,nDir,
                                 dObjConst,adC,adB,acConTypes,nNZ,anBegCol,
                                 pnLenCol,adA,anRowX,pdLower,pdUpper)
LS.check_error(pEnv,pnErrorCode[1])

@info "Loading Variable Tyeps---> calling LSloadVarType"
errorcode = LS.LSloadVarType(pModel,pachVarType)
LS.check_error(pEnv, errorcode)

@info "Setting Log Function ---> calling LSsetModelLogfunc"
errorcode = LS.LSsetModelLogfunc(pModel, logFunc, uDict)
LS.check_error(pEnv, errorcode)

errorcode = LS.LSsetMIPCallback(pModel,cbMIPFunc, uDict)
LS.check_error(pEnv, errorcode)

#solve the model
pnStatus = Int32[-1]
@info "Solving the model --> calling LSsolveMIP"
errorcode = LS.LSsolveMIP(pModel, pnStatus)
LS.check_error(pEnv, errorcode)

#retrieve the objective value
dObj = Cdouble[-1]
@info "Getting Objective value --> calling LSgetInfo"
errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_MIP_OBJ, dObj)
LS.check_error(pEnv, errorcode)


#retrieve the primal solution and variable types
@info "Quarrying variable types --> calling LSgetVarType"
varType = Vector{Cchar}(undef, nVars)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv, errorcode)
@info "Getting Primal solution solution --> calling LSgetMIPPrimalSolution"
padPrimal = Vector{Cdouble}(undef, nVars)
errorcode = LS.LSgetMIPPrimalSolution(pModel, padPrimal)
LS.check_error(pEnv, errorcode)
#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%s  %20s\n" "Primal" "Variable type"
println(repeat('=', 30))
for i in 1:nVars
    @printf "%.5f %10c \n" padPrimal[i] varType[i]
end
println()

#delete LINDO model pointer
@info "Deleting the model --> calling LSdeleteModel"
errorcode = LS.LSdeleteModel(pModel)
LS.check_error(pEnv, errorcode)

#delete LINDO environment pointer
@info "Deleting Enviroment --> calling LSdeleteEnv"
errorcode = LS.LSdeleteEnv(pEnv)
LS.check_error(pEnv, errorcode)


#=

[ Info: Loading License ---> calling LSloadLicenseString
[ Info: Creating Enviroment ---> calling LScreateEnv
[ Info: Creating Model ---> calling LScreateModel
[ Info: Loading LP data into model ---> calling LScreateModel
[ Info: Loading Variable Tyeps---> calling LSloadVarType
[ Info: Solving the model --> calling LSsolveMIP

Feasible obj value found in MIP prerelax heu=3.000000
Ori. size (m, n, nz,  nip):      5,      6,       15,       6


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
New  size (m, n, nz,  nip):      3,      4,        8,       4

Time Consumed in probing: 0.00 (sec.)



#BRANCHs  #NODEs    #LPs    BEST BOUND      BEST  IP     RGAP    TIME  OPTIME
(CUTPASS) (NUMCUT)            (SUMFP)                                   (CODE)

        0      0        0  -1.000000e+30   3.000000e+00 1.0e+00  0.00  (*K)
        0      0        0   3.000000e+00   3.000000e+00 0.0e+00  0.00  0.00  (100.00opt)

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


[ Info: Getting Objective value --> calling LSgetInfo
[ Info: Quarrying variable types --> calling LSgetVarType
[ Info: Getting Primal solution solution --> calling LSgetInfo
0

Objective is: 3.00000
Primal         Variable type
==============================
1.00000          B
0.00000          B
0.00000          B
0.00000          B
1.00000          B
1.00000          B

[ Info: Deleting the model --> calling LSdeleteModel
[ Info: Deleting Enviroment --> calling LSdeleteEnv

=#
