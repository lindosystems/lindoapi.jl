# Set up and solve a (quadratic) portfolio model with LINDO API.
#
#                    Portfolio Selection Problem
#                       The Markowitz Model.
#
#       MAXIMIZE  r(1)w(1) + ... +r(n)w(n)
#           st.       sum_{ij} Q(i,j)w(i)w(j) <= K
#                         w(1) + ..... + w(n)  = 1
#                         w(1),         ,w(n) >= 0
#           where
#           r(i)  : return on asset i
#           Q(i,j): covariance between the returns of i^th and
#                   j^th assets.
#           K     : a scalar denoting the level of risk of loss.
#           w(i)  : proportion of total budget invested on asset i

#           Covariance Matrix:
#                  w1    w2    w3    w4
#             w1 [ 1.00  0.64  0.27  0.    ]
#             w2 [ 0.64  1.00  0.13  0.    ]
#             w3 [ 0.27  0.13  1.00  0.    ]
#             w4 [ 0.    0.    0.    1.00  ]

#           Returns Vector:
#                    w1    w2    w3    w4
#           r =   [ 0.30  0.20 -0.40  0.20  ]

#           Risk of Loss Factor:
#           K = 0.4

import LINDO
using Printf
const LS = LINDO
PATH = ENV["LINDOAPI_HOME"]

# LP data
nM = 2
nN = 4
K = 0.20
objsense = LS.LS_MAX
objconst = 0
reward = Cdouble[0.300,0.200,-0.400,0.200]
rhs = Cdouble[K,1.0]
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
Qrowndx = Int32[0,0,0,0,0,0,0]
Qcolndx1 = Int32[0,0,0,1,1,2,3]
Qcolndx2 = Int32[0,1,2,1,2,2,3]
Q = Cdouble[1.0000,0.6400,0.2700,1.0000,0.1300,1.0000,1.0000]

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
errorcode = LS.LSloadLPData(pModel, nM, nN, objsense, objconst,
                                 reward, rhs, contype,
                                 Anz, Abegcol, Alencol, A, Arowndx,
                                 lb, ub)
LS.check_error(pEnv,pnErrorCode[1])

#load QP data into the model
@info "Loading QP data into model ---> calling LSloadQCData"
errorcode = LS.LSloadQCData(pModel, Qnz, Qrowndx,
                                 Qcolndx1, Qcolndx2, Q)
LS.check_error(pEnv,errorcode)

#solve the model
pnStatus = Int32[-1]
@info "Solving the model --> calling LSoptimize"
errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_FREE, pnStatus)
LS.check_error(pEnv,errorcode)

#retrieve the objective value
dObj = Cdouble[-1]
@info "Getting Objective value --> calling LSgetInfo"
errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, dObj)
LS.check_error(pEnv,errorcode)


#retrieve the primal solution and variable types
@info "Quarrying variable types --> calling LSgetVarType"
varType = Vector{UInt8}(undef, nN)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv,errorcode)

@info "Getting Primal solution solution --> calling LSgetPrimalSolution"
padPrimal = Vector{Cdouble}(undef, nN)
errorcode = LS.LSgetPrimalSolution(pModel, padPrimal)
LS.check_error(pEnv,errorcode)
#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%s  %20s\n" "Primal" "Variable type"
println(repeat('=', 30))
for i in 1:nN
    @printf "%.5f %10c \n" padPrimal[i] varType[i]
end
println()

#delete LINDO model pointer
@info "Deleting the model --> calling LSdeleteModel"
errorcode = LS.LSdeleteModel(pModel)
LS.check_error(pEnv,errorcode)

#delete LINDO environment pointer
@info "Deleting Enviroment --> calling LSdeleteEnv"
errorcode = LS.LSdeleteEnv(pEnv)
LS.check_error(pEnv,errorcode)


#=
[ Info: Loading License ---> calling LSloadLicenseString
[ Info: Creating Enviroment ---> calling LScreateEnv
[ Info: Creating Model ---> calling LScreateModel
[ Info: Loading LP data into model ---> calling LSloadLPData
[ Info: Loading QP data into model ---> calling LSloadQCData
[ Info: Solving the model --> calling LSoptimize
[ Info: Getting Objective value --> calling LSgetInfo
[ Info: Quarrying variable types --> calling LSgetVarType
[ Info: Getting Primal solution solution --> calling LSgetPrimalSolution

Objective is: 0.17316
Primal         Variable type
==============================
0.28110          C
0.21775          C
0.09158          C
0.40956          C

[ Info: Deleting the model --> calling LSdeleteModel
[ Info: Deleting Enviroment --> calling LSdeleteEnv
=#
