#=

  File: MOI_Callback.jl
  Breif: This script extends the MOI_wrapper.jl file used to set callback functions.
     This file contains default callback functions and MOI setter functions for
     custom functions.
     API Callbacks set:
        * LSsetCallback
        * LSsetGOPCallback
        * LSsetMIPCallback
        * LSsetModelLogfunc
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
 Type extentions
 Breif: These structs are implemented so that the
      MOI set function can be used.
=#
mutable struct LogFunction            <: MOI.AbstractCallback
    uData::Dict{Any,Any}
end
mutable struct CallbackFunction       <: MOI.AbstractCallback
    uData::Dict{Any,Any}
end
mutable struct GOPCallbackFunction    <: MOI.AbstractCallback
    uData::Dict{Any,Any}
end
mutable struct MIPCallbackFunction    <: MOI.AbstractCallback
    uData::Dict{Any,Any}
end

#=
 MOI.set
 Brief: Set a custom callback function.
 Example: MOI.set(model, Lindoapi.CallbackFunction(), foo)
     where:
     Lindoapi.CallbackFunction() - the type of callback function.
     foo - the callback subroutine.
=#
function MOI.set(model::Optimizer, cb_data::LogFunction, f::Function)
    model.usr_set_logfunc = true
    ret = LSsetModelLogfunc(model.ptr, f, cb_data.uData)
    _check_ret(model, ret)
    return
end

function MOI.set(model::Optimizer, cb_data::CallbackFunction, f::Function)
    model.usr_set_cbfunc = true
    ret = LSsetCallback(model.ptr, f, cb_data.uData)
    _check_ret(model, ret)
    return
end

function MOI.set(model::Optimizer, cb_data::GOPCallbackFunction, f::Function)
    model.usr_set_GOPcbfunc = true
    ret = LSsetGOPCallback(model.ptr, f, cb_data.uData)
    _check_ret(model, ret)
    return
end

function MOI.set(model::Optimizer, cb_data::MIPCallbackFunction, f::Function)
    model.usr_set_MIPcbfunc = true
    ret = LSsetMIPCallback(model.ptr, f, cb_data.uData)
    _check_ret(model, ret)
    return
end

#=

 Function: _setSolverCallback
 Breif: This function sets any required callback function.
        This function is called from Optimize!
        in MOI_wrapper.jl if model.silent == false.

=#
function _setSolverCallback(model::Optimizer)
    if model.usr_set_logfunc == false
        MOI.set(model, Lindoapi.LogFunction(uDict), logFunc)
    end
    if model.use_Global == true && model.usr_set_GOPcbfunc == false
        MOI.set(model, Lindoapi.GOPCallbackFunction(uDict), cbGOPFunc)
    elseif model.use_LSsolveMIP == true && model.usr_set_MIPcbfunc == false
        MOI.set(model, Lindoapi.MIPCallbackFunction(uDict), cbMIPFunc)
    else
        nothing
    end
    return
end
