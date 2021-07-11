# lindoapi-julia

Lindoapi a wrapper LINDO API 

This API gives you access to LINDO's powerful solvers for Stochastic, Linear, Nonlinear (convex & nonconvex/Global), Quadratic, Quadratically Constrained, Second Order Cone and Integer optimization.

Before adding the Lindoapi package please [download](https://www.lindo.com/index.php/ls-downloads/try-lindo-api) the API

See the [manual](https://www.lindo.com/downloads/PDF/API.pdf) for operating system specific downloading instructions and keep as a reference for the available API functions.

## Installation

For Windows

In a Dos command prompt 

```dos
> set LINDOAPI_HOME="c:/lindoapi"
```

For Mac and Linux
```sh
$ export LINDOAPI_HOME="/opt/lindoapi"  
```

To add the package in Julia
```julia
using Pkg
Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")
```

## Sample lp.jl

```julia
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

import Lindoapi
using Printf
const LS = Lindoapi
PATH = ENV["LINDOAPI_HOME"]

nCons = 4
nVars = 4
nDir = 1
dObjConst = 0.0
adC = Cdouble[1.0,1.0,1.0,1.0]
adB = Cdouble[20.0,20.0,40.0,10.0]
acConTypes = UInt8['E','G','E','G']
nNZ =  9
anBegCol = Int32[0,2,5,7,9]
pnLenCol = C_NULL
adA = Cdouble[3.0,4.0,6.0,5.0,7.0,8.0,1.0,2.0,9.0]
anRowX = Int32[0,2,1,2,3,2,3,0,1]
pdLower = Cdouble[2,1,-(LS.LS_INFINITY), -(LS.LS_INFINITY)]
pdUpper = Cdouble[5,LS.LS_INFINITY, 10, LS.LS_INFINITY]

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

#solve the model
pnStatus = Int32[-1]
@info "Solving the model --> calling LSoptimize"
errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_FREE, pnStatus)
LS.check_error(pEnv, errorcode)

#retrieve the objective value
dObj = Cdouble[-1]
@info "Getting Objective value --> calling LSgetInfo"
errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, dObj)
LS.check_error(pEnv, errorcode)


#retrieve the primal solution and variable types
@info "Quarrying variable types --> calling LSgetVarType"
varType = Vector{UInt8}(undef, nVars)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv, errorcode)
@info "Getting Primal solution solution --> calling LSgetPrimalSolution"
padPrimal = Vector{Cdouble}(undef, nVars)
errorcode = LS.LSgetPrimalSolution(pModel, padPrimal)
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
[ Info: Loading LP data into model ---> calling LSloadLPData
[ Info: Solving the model --> calling LSoptimize
[ Info: Getting Objective value --> calling LSgetInfo
[ Info: Quarrying variable types --> calling LSgetVarType
[ Info: Getting Primal solution solution --> calling LSgetPrimalSolution

Objective is: 10.44118 
Primal         Variable type
==============================
5.00000          C 
1.17647          C 
1.76471          C 
2.50000          C 

[ Info: Deleting the model --> calling LSdeleteModel
[ Info: Deleting Enviroment --> calling LSdeleteEnv
=#
```
