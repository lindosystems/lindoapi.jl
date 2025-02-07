"""
    A Julia programming example of interfacing with LINDO API using
    the soft wrapper. See path_to_samples/JuMP_interface/lp.jl
    for the same model using the JuMP interface.

  Purpose: Solve a NLP using the black-box style interface.
  Model  : A nonlinear model with multiple local minimizers.

        minimize  f(x,y) =  3*(1-x)^2*exp(-(x^2) - (y+1)^2)
                         - 10*(x/5 - x^3 - y^5)*exp(-(x^2)-y^2)
                         - 1/3*exp(-((x+1)^2) - y^2);
        subject to
                         x^2 + y   <=  6;
                         x   + y^2 <=  6;
                         x, y unconstrained in sign;

 To run sample
     include("/PathToUse/soft_wrapper/nlp.jl")

To update to the most current version of LindoAPI.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/LindoAPI.jl")
"""


import LindoAPI
using Printf
const LS = LindoAPI
PATH = ENV["LINDOAPI_HOME"]

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


# The objective value separated into five functions
g1(x, y) = exp(-x^2 - (y + 1)^2)
g2(x, y) = exp(-x^2 - y^2)
g3(x, y) = exp(-((x + 1)^2) - y^2)
f1(x, y) = (1 - x)^2
f2(x, y) = x/5 - x^3 - y^5

# the first partials (x and y) of the above five functions
dxg1(x, y) = -2*x*g1(x, y)
dyg1(x, y) = -2*(y+1)*g1(x, y)
dxg2(x, y) = -2*x*g2(x, y)
dyg2(x, y) = -2*y*g2(x, y)
dxg3(x, y) = -2*(x + 1)*g3(x, y)
dyg3(x, y) = -2y*g3(x, y)
dxf1(x, y) =  -2*(1 - x)
dyf1(x, y) =  0
dxf2(x, y) = (1/5 - 3*x^2)
dyf2(x, y) = -5*y^4

# A callback function to compute the objective and constraints
function cbFuncalc(pModel, udict, nRow, padPrimal, nJDiff, dXJBase, funcVal, reserved)
    x = padPrimal[1]
    y = padPrimal[2]
    if nRow == -1
        funcVal = 3*f1(x, y)*g1(x, y) - 10*f2(x, y)*g2(x, y) - g3(x, y)/3
    elseif nRow == 0
        funcVal = x*x + y   - 6.0
    else
        funcVal = x   + y*y - 6.0
    end
    return funcVal
end

# A callback function to compute the  gradienet of the objective and constraints
function cbGgradcalc(pModel, udict, nRow, padPrimal, lb, ub, isNewPoint, NPar, parlist, partial)
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

# LP data
nCons = 2
nVars = 2
nDir = 1
dObjConst = 0.0
adC = Cdouble[0.0,0.0]
adB = Cdouble[0.0,0.0]
acConTypes = UInt8['L','L']
nNZ = 2
Abegcol = Int32[0,2,4]
Alencol = Int32[2,2]
Acoef = Cdouble[0.,1.,1.,0.]
Arowndx = Int32[0,1,0,1]
lb = Cdouble[-3.,-3.]
ub = Cdouble[3.,3.]
pachVarType = UInt8['C','C']
# NLP data
# The number of nonlinear variables in each column
Alencol[1]=1; Alencol[2]=1;
# The indices of the first nonlinear variable in each column
Abegcol[1]=0; Abegcol[2]=1; Abegcol[3]=2;
# The indices of nonlinear constraints
Arowndx[1]=0; Arowndx[2]=1;
Nobjndx = Int32[0,1]
Nnlobj = 2
# variable starting value
x_start = 0.25
y_start = -1.65;

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
                pModel,nCons,nVars,nDir,
                dObjConst,adC,adB,acConTypes,nNZ,Abegcol,
                Alencol,Acoef,Arowndx,lb,ub
                )
LS.check_error(pEnv, errorcode)

# Loading data NLP data
errorcode = LS.LSloadNLPData(
                pModel,Abegcol,Alencol,
                C_NULL,Arowndx,Nnlobj,Nobjndx, C_NULL
                )
LS.check_error(pEnv, errorcode)

# Setting the callback function
errorcode = LS.LSsetCallback(pModel, cbFunc, uDict)                             # cbFunc and uDict is defined above
LS.check_error(pEnv, errorcode)

# Set callback function that calculates
# Objective and constraints functions
errorcode = LS.LSsetFuncalc(pModel,cbFuncalc, uDict)
LS.check_error(pEnv, errorcode)

# Set callback function that calculates
# Objective and constraints gradients
errorcode = LS.LSsetGradcalc(pModel,cbGgradcalc, uDict, 3, [-1,0,1])
LS.check_error(pEnv, errorcode)

# Setting an optional parameter
errorcode = LS.LSsetModelIntParameter(pModel, LS.LS_IPARAM_NLP_MAXLOCALSEARCH , 5)
LS.check_error(pEnv, errorcode)

# Setting the start values for more optimal
padPrimal = Vector{Cdouble}(undef, nVars)
padPrimal[1] = x_start;  padPrimal[2] = y_start;
errorcode = LS.LSloadVarStartPoint(pModel,padPrimal)
LS.check_error(pEnv, errorcode)

# Calling the optimizer
pnStatus = Int32[-1]
errorcode = LS.LSoptimize(pModel, LS.LS_METHOD_FREE, pnStatus)
LS.check_error(pEnv, errorcode)

# Get Objective value
dObj = Cdouble[-1.0]
errorcode = LS.LSgetInfo(pModel, LS.LS_DINFO_POBJ, dObj)
LS.check_error(pEnv, errorcode)

# Primal values
errorcode = LS.LSgetPrimalSolution(pModel,padPrimal)
LS.check_error(pEnv, errorcode)

# retrieve the primal solution and variable types
varType = Vector{UInt8}(undef, nVars)
errorcode = LS.LSgetVarType(pModel, varType)
LS.check_error(pEnv, errorcode)

# Printing out objective value and primal solution
println()
@printf "Objective is: %.5f \n" dObj[1]
@printf "%10s  %15s\n" "Primal" "Variable type"
println(repeat('=', 30))
for i in 1:nVars
    @printf "%10.5f %10c \n" padPrimal[i] varType[i]
end
println()

# delete LINDO model pointer
errorcode = LS.LSdeleteModel(pModel)
LS.check_error(pEnv, errorcode)

# delete LINDO environment pointer
errorcode = LS.LSdeleteEnv(pEnv)
LS.check_error(pEnv, errorcode)


#=             Output

NLP local optimizer started.

  Iter  Phase   nInf         Objective    Pinf(sum)  Dinf(rgmax)      Time
     0      0      0   1.00000000e+030   1.000e+000   0.000e+000      0.07
    15      4      0  -6.54282103e+000   0.000e+000   1.658e-012      0.07

NLP local optimizer terminated, obj:-6.54282, pfeas:0, status:8 (err: 0).



Used Method        = 7
Used Time          = 0
Refactors (ok,stb) = 0 (-1.#J,-1.#J)
Simplex   Iters    = 0
Barrier   Iters    = 0
Nonlinear Iters    = 15
Primal Status      = 8
Dual   Status      = 12
Basis  Status      = 14
Primal Objective   = -6.5428210253290429
Dual   Objective   = -6.5428210253290429
Duality Gap        = 0.000000e+000
Primal Infeas      = 0.000000e+000
Dual   Infeas      = 1.658298e-012


Solution is locally optimal.

Objective is: -6.54282
    Primal    Variable type
==============================
   0.22360          C
  -1.64992          C

  =#
