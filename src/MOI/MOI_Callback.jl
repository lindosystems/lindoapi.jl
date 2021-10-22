#=

  File: MOI_Callback.jl
  Breif: This file contains the callback subroutines that are passed as arguments
     to the API callback functions. It also contains a function sets the callback functions.
     This file is used with the MOI_wrapper.jl, but does not implement and MOI functions.
     The function _setSolverCallback is called by optimize! when model.silent == false.

=#

using Printf

#=
 User pass through data for callback functions.
 Currently There is no way for a user to access this uDict to edit
 and the none of the call back function are printing any of its data.
=#
uDict = Dict(
"Prefix" => "Lindo API",
"Postfix" => "...",)

#=

 Function: logFunc
 Brief:    The subroutine passed as an argument to LSsetModelLogfunc.

=#
function logFunc(modelPtr, line, uDict)
  @printf "%s" line
end

#=

 Function: cbMIPFunc
 Brief:    The subroutine passed as an argument to LSsetGOPCallback.
            prints out the curent itteration and objective value when called.

=#
function cbMIPFunc(modelPtr, uDict, objValue, pimalValues)
    dIter = Cdouble[-1.0]
    ret = LSgetProgressInfo(modelPtr, 0, LS_DINFO_CUR_ITER, dIter)
    @printf "\nMIP Solver | Iter:%g, Obj=%g"  dIter[1] objValue
end

#=

 Function: cbGOPFunc
 Brief:    The subroutine passed as an argument to LSsetGOPCallback.
            prints out the curent itteration and objective value when called.

=#
function cbGOPFunc(modelPtr, uDict, objValue, pimalValues)
    dIter = Cdouble[0]
    ret = LSgetProgressInfo(modelPtr, 0, LS_DINFO_CUR_ITER, dIter)
    @printf "\nGlobal Solver | Iter:%g, Obj=%g"  dIter[1] objValue
end

#=

 Function: _setSolverCallback
 Breif: This function sets any required callback function.
        This function is called from Optimize!
        in MOI_wrapper.jl if model.silent == false.

=#
function _setSolverCallback(model::Optimizer)
    if model.use_Global == true
        ret = LSsetModelLogfunc(model.ptr, logFunc, uDict)
        _check_ret(model, ret)
        ret = LSsetGOPCallback(model.ptr, cbGOPFunc, uDict)
        _check_ret(model, ret)
    elseif model.use_LSsolveMIP == true
         ret = LSsetModelLogfunc(model.ptr, logFunc, uDict)
         _check_ret(model, ret)
        ret = LSsetMIPCallback(model.ptr, cbMIPFunc, uDict)
        _check_ret(model, ret)
    else
        ret = LSsetModelLogfunc(model.ptr, logFunc, uDict)
        _check_ret(model, ret)
    end
    return
end
