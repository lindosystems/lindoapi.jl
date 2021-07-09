
#  File   : Derived from samples/c/ex_nlp1/ex_nlp1.c
#
#  Purpose: Solve a NLP using the black-box style interface.
#  Model  : A nonlinear model with multiple local minimizers.
#
#        minimize  f(x,y) =  3*(1-x)^2*exp(-(x^2) - (y+1)^2)
#                         - 10*(x/5 - x^3 - y^5)*exp(-(x^2)-y^2)
#                         - 1/3*exp(-((x+1)^2) - y^2);
#        subject to
#                         x^2 + y   <=  6;
#                         x   + y^2 <=  6;
#                         x, y unconstrained in sign;
import LINDO
using Printf
const LS = LINDO
PATH = ENV["LINDOAPI_HOME"]

uDict = Dict(
"Prefix" => "Lindo API",
"Postfix" => "...",)

function logEnvFunc(pModel,line, uDict)
  @printf "Env => %s" line
  flush(Base.stdout)
end

function logFunc(pModel,line, uDict)
  @printf "%s" line
  flush(Base.stdout)
end

function cbMIPFunc(pModel, uDict, dObj, padPrimal)
    dIter = Cdouble[-1.0]
    errorcode = LS.LSgetProgressInfo(pModel, 0, LS.LS_DINFO_CUR_ITER, dIter)
    @printf "\ncbMIPFunc | Iter:%g, Obj=%g"  dIter[1] dObj
    for i in 1:length(padPrimal)
        @printf "\n%.5f " padPrimal[i]
    end
end

g1(x, y) = exp( -x^2 - (y + 1)^2)
g2(x, y) = exp(-x^2 - y^2)
g3(x, y) = exp( -((x+1)^2) - y^2)
f1(x, y) = (1 - x)^2
f2(x, y) = x/5 - x^3 - y^5

dxg1(x, y) = -2*x*g1(x, y)
dyg1(x, y) = -2*(y+1)*g1(x, y)
dxg2(x, y) = -2*x*g2(x, y)
dyg2(x, y) = -2*y*g2(x, y)
dxg3(x, y) = -2*(x + 1)*g3(x, y)
dyg3(x, y) = -2y*g3(x, y)
dxf1(x, y) = 2*(1 - x)
dyf1(x, y) = 0
dxf2(x, y) = (1/5 - 3*x^2)
dyf2(x, y) = -5*y^4

function cbFuncalc(pModel, udict, nRow, padPrimal, nJDiff, dXJBase, funcVal, reserved)
    # compute objective's functional value
    x = padPrimal[1]
    y = padPrimal[2]
    if nRow == -1
        funcVal = 3*f1(x, y)*g1(x, y) - 10*f2(x, y)*g2(x, y) - g3(x, y)/3
    elseif nRow == 0
        funcVal = x^2 + y - 6.0
    else
        funcVal = x + y^2 - 6.0
    end
    return funcVal
end

function cbGgradcalc(pModel, udict, nRow, padPrimal, lb, ub, isNewPoint, NPar, parlist, partial)
    # compute objective's functional value
    x = padPrimal[1]
    y = padPrimal[2]

    for i2 in 1:NPar
        partial[i2] = 0.0
    end
    if nRow == -1
        for i2 in 1:NPar
            if lb[parlist[i2]+1] != ub[parlist[i2]+1]
                if (parlist[i2]==0)
                    partial[i2]= 3*(dxf1(x,y)*g1(x,y) + f1(x,y)*dxg1(x,y) ) -  10*(dxf2(x,y)*g2(x,y) + f2(x,y)*dxg2(x,y) ) - 1/3*(dxg3(x,y))
                else
                    partial[i2]= 3*(dyf1(x,y)*g1(x,y) + f1(x,y)*dyg1(x,y) ) -  10*(dyf2(x,y)*g2(x,y) + f2(x,y)*dyg2(x,y) ) - 1/3*(dyg3(x,y))
                end
            end
        end
    elseif nRow == 0
        for i2 in 1:NPar
            if (lb[parlist[i2]+1]!=ub[parlist[i2]+1])
                if (parlist[i2]==0)
                    partial[i2]=2.0*x
                else
                    partial[i2]=1
                end
            end
        end
    else
        for i2 in 1:NPar
            if (lb[parlist[i2]+1]!=ub[parlist[i2]+1])
                if (parlist[i2]==0)
                    partial[i2]=1
                else (parlist[i2]==1)
                    partial[i2]=2.0*y
                end
            end
        end
    end
    return partial
end

#model LP data
nCons = 2
nVars = 2
nDir = 1
dObjConst = 0.0
adC = Cdouble[0.0,0.0]
adB = Cdouble[0.0,0.0]
acConTypes = UInt8['L','L']
nNZ = 4
Abegcol = Int32[0,2,4]
Alencol = Int32[2,2]
Acoef = Cdouble[0.,1.,1.,0.]
Arowndx = Int32[0,1,0,1]
lb = Cdouble[-3.,-3.]
ub = Cdouble[3.,3.]
pachVarType = UInt8['C','C']
# NLP data
Nobjndx = Int32[0,1]
Nnlobj = 2

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
                                 dObjConst,adC,adB,acConTypes,nNZ,Abegcol,
                                 Alencol,Acoef,Arowndx,lb,ub)
LS.check_error(pEnv,pnErrorCode[1])

@info "Loading Variable Tyeps---> calling LSloadVarType"
errorcode = LS.LSloadVarType(pModel,pachVarType)
LS.check_error(pEnv, errorcode)

#load NLP data
# The number of nonlinear variables in each column
Alencol[1]=1; Alencol[2]=1;
# The indices of the first nonlinear variable in each column
Abegcol[1]=0; Abegcol[2]=1; Abegcol[3]=2;
# The indices of nonlinear constraints
Arowndx[1]=0; Arowndx[2]=1;

@info "Loading NLP data into model---> calling LSloadNLPData"
errorcode = LS.LSloadNLPData(pModel,Abegcol,Alencol,
        C_NULL,Arowndx,Nnlobj,Nobjndx, C_NULL)
LS.check_error(pEnv, errorcode)

@info "Setting Model Log Function ---> calling LSsetEnvLogfunc"
errorcode = LS.LSsetEnvLogfunc(pModel, logEnvFunc, uDict)
LS.check_error(pEnv, errorcode)

@info "Setting Env Log Function ---> calling LSsetModelLogfunc"
errorcode = LS.LSsetModelLogfunc(pModel, logFunc, uDict)
LS.check_error(pEnv, errorcode)

# @info "Setting MIP Call Back ---> calling LSsetMIPCallback"
# errorcode = LSsetMIPCallback(pModel,cbMIPFunc, uDict)
# check_error(pEnv, errorcode)

@info "Setting Function Calc---> calling LSsetFuncalc"
errorcode = LS.LSsetFuncalc(pModel,cbFuncalc, uDict)
LS.check_error(pEnv, errorcode)

@info "Setting Gradienet Calc---> calling LSsetGradcalc"
errorcode = LS.LSsetGradcalc(pModel,cbGgradcalc, uDict, 3, [-1,0,1])
LS.check_error(pEnv, errorcode)

@info "Setting Interger parameter---> calling LSsetModelIntParameter"
errorcode = LS.LSsetModelIntParameter(pModel, LS.LS_IPARAM_NLP_MAXLOCALSEARCH , 5)
LS.check_error(pEnv, errorcode)

###############################
# Get model stats
ibuf = Int32[1]
@info "Getting number of continuous variables ---> calling LSgetInfo"
errorcode = LS.LSgetInfo(pModel, LS.LS_IINFO_NUM_CONT,ibuf) # number of continuous variables
LS.check_error(pEnv, errorcode)
nCont = ibuf[1]

#####################################
## Load initial solution
padPrimal = Vector{Cdouble}(undef, nVars)
padPrimal[1] = 0.25;  padPrimal[2] = -1.65;
errorcode = LS.LSloadVarStartPoint(pModel,padPrimal)
LS.check_error(pEnv, errorcode)

#####################################
## Solve the model
println("Solving the model...")
pnStatus = Int32[-1]

if nCont<nVars
    @info "Solving MIP ---> calling LSsolveMIP"
    errorcode = LS.LSsolveMIP(pModel,pnStatus)
else
    @info "Solving NLP ---> calling LSoptimize"
    errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_FREE, pnStatus)
end
LS.check_error(pEnv, errorcode)

#####################################
## Retrieve the objective value
dObj = Cdouble[-1.0]
if nCont<nVars
    errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_MIP_OBJ, dObj)
else
    errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, dObj)
end
LS.check_error(pEnv, errorcode)
#####################################
## Retrieve the primal solution
if nCont<nVars
    errorcode = LS.LSgetMIPPrimalSolution(pModel,padPrimal)
else
    errorcode = LS.LSgetPrimalSolution(pModel,padPrimal)
end
LS.check_error(pEnv, errorcode)

#retrieve the primal solution and variable types
@info "Quarrying variable types --> calling LSgetVarType"
varType = Vector{UInt8}(undef, nVars)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv, errorcode)

#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%10s  %15s\n" "Primal" "Variable type"
println(repeat('=', 30))
for i in 1:nVars
    @printf "%10.5f %10c \n" padPrimal[i] varType[i]
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
