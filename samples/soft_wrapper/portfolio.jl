#=

Bzsed on
  File   : port.c
  Purpose: Solve a quadratic mixed integer programming problem.
  Model  : Portfolio Selection Problem with a Restriction on
           the Number of Assets
           MINIMIZE   0.5 w'Q w
                   s.t.   sum_i  w(i)              =  1
                          sum_i  r(i)w(i)         >=  R
                          for_i  w(i) - u(i) x(i) <=  0   i=1...n
                          sum_i  x(i)             <=  K
                          for_i  x(i) are binary
                   where
                   r(i)  : return on asset i.
                   u(i)  : an upper bound on the proportion of total budget
                           that could be invested on asset i.
                   Q(i,j): covariance between the returns of i^th and j^th
                           assets.
                   K     : max number of assets allowed in the portfolio
                   w(i)  : proportion of total budget invested on asset i
                   x(i)  : a 0-1 indicator if asset i is invested on.
=#

import Lindoapi
using Printf
const LS = Lindoapi
PATH = ENV["LINDOAPI_HOME"]

# number of constraints
nM = 10
# number of assets (7) plus number of indicator variables (7)
nN = 14

# LP Data
# Maximum number of assets allowed in a Portfolio
K = 3
# The target return
R = 0.30
# direction of optimization
objsense = LS.LS_MIN
# The objective's constant term
dObjConst = 0.0
# there are no linear components in the objective function
c = Cdouble[0,0,0,0,0,0,0,0,0,0,0,0,0,0,]
# right hand-side of the constraints
rhs = Cdouble[1.0, R, 0, 0, 0, 0, 0, 0, 0, K]
# constraint types
contype = Cchar['E','G','L','L','L','L','L','L','L','L']
# THe number of nonzeros in the constraint matrix
Anz = 35
# The indices of th efirst nonzero in each column
Abegcol = Int32[0,  3,  6,  9, 12, 15, 18, 21, 23, 25, 27, 29, 31, 33, Anz]
# The length of each column. Since we aren't leaving
# any blanks in our matrix, we can set this to NULL
Alencol = C_NULL
# The nonzero coefficients
A = [1.00, 0.14, 1.00,
1.00, 0.77, 1.00,
1.00, 0.28, 1.00,
1.00, 0.17, 1.00,
1.00, 0.56, 1.00,
1.00, 0.18, 1.00,
1.00, 0.70, 1.00,
-0.04, 1.00,
-0.56, 1.00,
-0.37, 1.00,
-0.32, 1.00,
-0.52, 1.00,
-0.38, 1.00,
-0.25, 1.00 ]
# The row indices of the nonzero coefficients
Arowndx = Int32[0, 1, 2, 0, 1, 3, 0, 1, 4, 0, 1, 5,
0, 1, 6, 0, 1, 7, 0, 1, 8, 2, 9, 3,
9, 4, 9, 5, 9, 6, 9, 7, 9, 8, 9]
# By default, all variables have a lower bound of zero
# and an upper bound of infinity Therefore set to C_NULL
lb = C_NULL
ub = C_NULL
# Quadratic Matrix
# The number of nonzeros in the quadratic matrix
Qnz = 28
Q = Cdouble[
 1.00,  0.11,  0.04,  0.02,  0.08,  0.03,  0.10,
 1.00,  0.21,  0.13,  0.43,  0.14,  0.54,
 1.00,  0.05,  0.16,  0.05,  0.20,
 1.00,  0.10,  0.03,  0.12,
 1.00,  0.10,  0.40,
 1.00,  0.12,
 1.00]
# The row indices of the nonzero coefficients in the Q-matrix
Qrowndx = Int32[ -1, -1, -1, -1, -1, -1, -1,
-1, -1, -1, -1, -1, -1,
-1, -1, -1, -1, -1,
-1, -1, -1, -1,
-1, -1, -1,
-1, -1,
-1]

# The indices of the first nonzero in each column in the Q-matrix
Qcolndx1 = Int32[ 0, 1, 2, 3, 4, 5, 6,
1, 2, 3, 4, 5, 6,
2, 3, 4, 5, 6,
3, 4, 5, 6,
4, 5, 6,
5, 6,
6]
Qcolndx2 = Int32[0, 0, 0, 0, 0, 0, 0,
1, 1, 1, 1, 1, 1,
2, 2, 2, 2, 2,
3, 3, 3, 3,
4, 4, 4,
5, 5,
6]

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
@info "Loading LP data into model ---> calling LScreateModel"
errorcode = LS.LSloadLPData(pModel, nM, nN, objsense, dObjConst,
                            c, rhs, contype,
                            Anz, Abegcol, Alencol, A, Arowndx,
                            lb, ub)
LS.check_error(pEnv,pnErrorCode[1])

#load QP data into the model
@info "Loading QP data into model ---> calling LScreateModel"
errorcode = LS.LSloadQCData(pModel, Qnz, Qrowndx,
                                 Qcolndx1, Qcolndx2, Q)
LS.check_error(pEnv,errorcode)


@info "Loading Variable Tyeps---> calling LSloadVarType"
pachVarType = Cchar['C','C','C','C','C','C','C','B','B','B','B','B','B','B']
errorcode = LS.LSloadVarType(pModel,pachVarType)
LS.check_error(pEnv, errorcode)

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
varType = Vector{Cchar}(undef, nN)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv, errorcode)
@info "Getting Primal solution solution --> calling LSgetInfo"
padPrimal = Vector{Cdouble}(undef, nN)
errorcode = LS.LSgetMIPPrimalSolution(pModel, padPrimal)
LS.check_error(pEnv, errorcode)
#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%s  %20s\n" "Primal" "Variable type"
println(repeat('=', 30))
for i in 1:(div(nN,2))
    @printf "Invest %.5f percent of total budget in asset %d \n" 100*padPrimal[i] i
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
