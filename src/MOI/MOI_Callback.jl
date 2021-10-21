#=


=#

using Printf

#=



=#
uDict = Dict(
"Prefix" => "Lindo API",
"Postfix" => "...",)

#=

 Function

=#
function cbGOPFunc(pModel, uDict, dObj, padPrimal)
    dIter = Cdouble[-1.0]
    errorcode = LSgetProgressInfo(pModel, 0, LS_DINFO_CUR_ITER, dIter)
    @printf "\nGlobal Solver | Iter:%g, Obj=%g"  dIter[1] dObj
end

#=

 Function _setSolverCallback

=#
function _setSolverCallback(model::Optimizer)
    ret = LSsetGOPCallback(model.ptr, cbGOPFunc, uDict)
    _check_ret(model, ret)
end
