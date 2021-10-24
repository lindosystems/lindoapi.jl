#=

 File: liblindo_api_callback.jl
 Brief: This file is separate from liblindo_api since it has code
    that is not generated by Clang.jl, and should be kept separate
    for future updates.

 Bugs:

=#

#=

 mutable struct: jlLindoData_t
 Brief: A data type that holds user callback functions
    and callback data

=#
# maintains user defined julia objects
mutable struct jlLindoData_t
    _cbMIPFunc::Union{Nothing, Function}
    _cbGOPFunc::Union{Nothing, Function}
    _cbModelLogFunc::Union{Nothing, Function}
    _cbEnvLogFunc::Union{Nothing, Function}
    _funCalcFunc::Union{Nothing, Function}
    _gradCalcFunc::Union{Nothing, Function}
    _cbData::Union{Nothing, Dict{String, String}}

#=
 Function: jlLindoData_t
 Brief: an empty constructor if a jlLindoData_t
=#
    function jlLindoData_t()
        return new(nothing,nothing,
        nothing,nothing,nothing,nothing)
    end
end

#=
 Global dictionary that can index jlLindoData_t
 by a model pointer or and environment pointer.
=#
udata_Dict = Dict{Union{pLSmodel, pLSenv}, jlLindoData_t}()

#=
 Function: check_error
 Brief: Wraps LSgetErrorMessage to display error message and
  throw an error.
=#
function check_error(pEnv, ErrorCode)
    if ErrorCode != 0
        pachMessage = Vector{UInt8}(undef,1024)
        LSgetErrorMessage(pEnv, ErrorCode, pachMessage)
        cast_pachMessage = unsafe_string(pointer(pachMessage))
        error("Error --> $(cast_pachMessage)")
    else
        nothing
    end
    return
end

#=
 Function: addToUdata
 Brief: Adds a key to the global dictionary udata_Dict If the model or
  environment has not been added to it.
=#
function addToUdata(key::Union{pLSmodel, pLSenv})
    if isUdata(key) == false
        udata_Dict[key] = jlLindoData_t()
    end
end
#=

 Function: isUdata
 Brief: Checks if a model or environment has been made into a key.

=#
function isUdata(key::Union{pLSmodel, pLSenv})
    ret = getkey(udata_Dict, key, -1)
    if ret == -1
        return false
    else
        return true
    end
end


"""

    Function: relayXXX
       Brief: Marshal the C data from API into Julia data to call the
        user defined callback function written in Julia then Marshal
        the Julia data back into C data. The macro @cfunction is used
        to turn relayXXX into a C-callable function pointer.

    Function: LSXXX
       Brief: Modified from Clang.jl generated functions to handle
        its relayXXX function.

"""

function relayMIPCallback(pModel, uData, dObj, padPrimal)
    # get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
    end
    uData._cbMIPFunc(pModel, uData._cbData, dObj, jl_padPrimal)
    return Int32(0)
end

function LSsetMIPCallback(pModel, pfMIPCallback, pvCbData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvCbData
    udata_Dict[pModel]._cbMIPFunc = pfMIPCallback
    relayMIPCallback_c = @cfunction(relayMIPCallback, Cint, (pLSmodel, Ref{jlLindoData_t}, Cdouble, Ptr{Cdouble}))
    ccall((:LSsetMIPCallback, liblindo), Cint, (pLSmodel, cbFunc_t, Ref{jlLindoData_t}), pModel, relayMIPCallback_c, udata_Dict[pModel])
end

function relayGOPCallback(pModel, uData, dObj, padPrimal)
    # get number of variales
    # get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
    end
    uData._cbGOPFunc(pModel, uData._cbData, dObj, jl_padPrimal)
    return Int32(0)
end

function LSsetGOPCallback(pModel, pfGOP_caller, pvPrData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvPrData
    udata_Dict[pModel]._cbGOPFunc = pfGOP_caller
    relayGOPCallback_c = @cfunction(relayGOPCallback, Cint, (pLSmodel, Ref{jlLindoData_t}, Cdouble, Ptr{Cdouble}))
    ccall((:LSsetGOPCallback, liblindo), Cint, (pLSmodel, GOP_callback_t, Ref{jlLindoData_t}), pModel, relayGOPCallback_c, udata_Dict[pModel])
end

function relayGradcalc(pModel, uData, nRow, padPrimal, lb, ub, isNewPoint, nNPar, pnParList, pdPartial)
# get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    jl_pnParList = Vector{Cint}(undef, nVar[1])
    jl_lb = Vector{Cdouble}(undef, nVar[1])
    jl_ub = Vector{Cdouble}(undef, nVar[1])
    jl_pdPartial = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
        jl_pnParList[i] = unsafe_load(pnParList,i)
        jl_lb[i] = unsafe_load(lb,i)
        jl_ub[i] = unsafe_load(ub,i)
        jl_pdPartial[i] = unsafe_load(pdPartial,i)
    end
    uData._gradCalcFunc(pModel, uData._cbData, nRow, jl_padPrimal, jl_lb, jl_ub, isNewPoint, nNPar, jl_pnParList, jl_pdPartial)
    # marshall data from julia to C
    unsafe_store!(pdPartial, jl_pdPartial[1])

    return Int32(0)
end

function LSsetGradcalc(pModel, pfGrad_func, pvUserData, nLenUseGrad, pnUseGrad)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvUserData
    udata_Dict[pModel]._gradCalcFunc = pfGrad_func
    relayGradcalc_c = @cfunction(relayGradcalc, Cint, (pLSmodel, Ref{jlLindoData_t}, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Ptr{Cint}, Ptr{Cdouble}))
    ccall((:LSsetGradcalc, liblindo), Cint, (pLSmodel, Gradcalc_type, Ref{jlLindoData_t}, Cint, Ptr{Cint}), pModel, relayGradcalc_c, udata_Dict[pModel], nLenUseGrad, pnUseGrad)
end

function relayFuncalc(pModel, udata, nRow, padPrimal, nJdiff, dxJBase, funcVal, reserved)
    # get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_funcval = unsafe_load(funcVal)
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
    end
    jl_funcval =  udata._funCalcFunc(pModel, udata._cbData, nRow, jl_padPrimal, nJdiff, dxJBase, funcVal ,  reserved)
    # marshall the julia data to C
    unsafe_store!(funcVal, jl_funcval)
    return Int32(0)
end

function LSsetFuncalc(pModel, pfFunc, pvFData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvFData
    udata_Dict[pModel]._funCalcFunc = pfFunc
    relayFuncalc_c = @cfunction(relayFuncalc, Cint, (pLSmodel,  Ref{jlLindoData_t} ,Cint, Ptr{Cdouble}, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cvoid}))
    ccall((:LSsetFuncalc, liblindo), Cint, (pLSmodel, Funcalc_type, Ref{jlLindoData_t}), pModel, relayFuncalc_c, udata_Dict[pModel])
end

function relayEnvLogfunc(pEnv, line, udata)
    jlLine = unsafe_string(line)
    udata._cbEnvLogFunc(pEnv, jlLine, udata._cbData)
    return Int32(0)
end

function LSsetEnvLogfunc(pEnv, pfLocFunc, pvPrData)
    addToUdata(pEnv)
    udata_Dict[pEnv]._cbData = pvPrData
    udata_Dict[pEnv]._cbEnvLogFunc = pfLocFunc
    relayEnvLogfunc_c = @cfunction(relayEnvLogfunc, Cint, (pLSenv, Ptr{Cchar}, Ref{jlLindoData_t}))
    ccall((:LSsetEnvLogfunc, liblindo), Cint, (pLSenv, printEnvLOG_t, Ref{jlLindoData_t}), pEnv, relayEnvLogfunc_c, udata_Dict[pEnv])
end

function relayModelLogfunc(pModel, line, udata)
    jlLine = unsafe_string(line)
    udata._cbModelLogFunc(pModel, jlLine, udata._cbData)
    return Int32(0)
end

function LSsetModelLogfunc(pModel, pfLogFunc, pvPrData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvPrData
    udata_Dict[pModel]._cbModelLogFunc = pfLogFunc
    relayModelLogfunc_c = @cfunction(relayModelLogfunc, Cint, (pLSmodel, Ptr{Cchar}, Ref{jlLindoData_t}))
    ccall((:LSsetModelLogfunc, liblindo),
     Cint, (pLSmodel, printModelLOG_t, Ref{jlLindoData_t}), pModel, relayModelLogfunc_c, udata_Dict[pModel])
end