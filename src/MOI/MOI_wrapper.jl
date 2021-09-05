import MathOptInterface

const MOI = MathOptInterface
const CleverDicts = MOI.Utilities.CleverDicts
const _HASH = CleverDicts.key_to_index
const _INVERSE_HASH = x -> CleverDicts.index_to_key(MOI.VariableIndex, x)
const PATH = ENV["LINDOAPI_HOME"]

const _SUPPORTED_OBJECTIVE_FUNCTION = Union{Nothing, MOI.AbstractFunction}

const _CON_TYPE = Dict(
    :>= => LS_CONTYPE_GE,
    :<= => LS_CONTYPE_LE,
    :(==) => LS_CONTYPE_EQ,)

const _SENSE = Dict(
    MOI.MIN_SENSE => LS_MIN,
    MOI.MAX_SENSE => LS_MAX,)


# @enum EnumName[::BaseType] value1[=x] value2[=y]
@enum( _ObjectiveType,
    _SCALAR_AFFINE
)

@enum(
    _BoundType,
    _NONE,
    _LESS_THAN,
    _GREATER_THAN,
    _LESS_AND_GREATER_THAN,
    _INTERVAL,
    _EQUAL_TO,
)

mutable struct _VariableInfo
    index::MOI.VariableIndex
    column::Int
    bound::_BoundType
    lower_bound_bounded::Float64
    upper_bound_bounded::Float64
    name::String

    function _VariableInfo(index::MOI.VariableIndex, column::Int)
        # Construct a defulat variable
        variable_info = new(index, column)
        variable_info.index = index
        variable_info.column = column
        variable_info.bound = _NONE
        variable_info.lower_bound_bounded = 0.0
        variable_info.upper_bound_bounded = typemax(Float64)
        variable_info.name = ""
        return variable_info
    end
end

mutable struct Env
    ptr::Ptr{Cvoid}
    key::Vector{UInt8}
    pn_error_code::Vector{Int32}
    finalize_called::Bool
    attached_models::Int

    function Env()
        # pszFname
        fn = joinpath(PATH, "license/lndapi130.lic")
        key = Vector{UInt8}(undef, 1024)
        # LSloadLicenseString(pszFname, pachLicense)
        ret = LSloadLicenseString(fn, key)
        if ret != 0
            error("Key not found check key $(license_path)")
        end
        # ptr = LScreateEnv(pnErrorcode, pszPassword)
        pn_error_code = Int32[-1]
        ptr = LScreateEnv(pn_error_code, key)
        if pn_error_code[1] != 0
            error("Lindo Error $(pn_error_code[1]): Unable to create Lindo eviroment!")
            exit(0)
        end

        env = new(ptr, key, pn_error_code, false, 0)

        finalizer(env) do e
            e.finalize_called = true
            if e.attached_models == 0
                ret = LSdeleteEnv(env.ptr)
                if ret != 0
                     error("Lindo Error $(ret): Unable to delete enviroment")
                     exit(0)
                 end
                e.ptr = C_NULL
            end
        end
    end
end

Base.cconvert(::Type{Ptr{Cvoid}}, x::Env) = x
Base.unsafe_convert(::Type{Ptr{Cvoid}}, env::Env) = env.ptr::Ptr{Cvoid}

mutable struct Optimizer <: MOI.AbstractOptimizer
"""
    Represnets an instance of an optimization problem tied to the Lindo solver.
This is typically a solvers's in memory represntation. In addition to ModelLike,
AbstractOptimizer objects let you solve the model and query the solution.
    Wrapping a solver in C will require the use of pointes, and memory management.
The pointer is stored as a feild.
"""
    env::Union{Nothing,Env}
    ptr::pLSmodel
    # A flag to keep track of MOI.Silent
    # An optimizer attribute for silencing the output of an optimizer.
    silent::Bool
    #
    # An enum to remember what objective is currently stored in the model.
    objective_type::_ObjectiveType
    #
    objective_function::_SUPPORTED_OBJECTIVE_FUNCTION
    #
    # NLP
    nlp_data::MOI.NLPBlockData
    nlp_count::Int
    #
    objective_sense::MOI.OptimizationSense
    lindoTerminationStatus::Int
    # Use to track the next variable
    next_column::Int
    #
    primal_values::Vector{Cdouble}
    primal_retrived::Bool

    variable_info::CleverDicts.CleverDict{
        MOI.VariableIndex,
        _VariableInfo,
        typeof(_HASH),
        typeof(_INVERSE_HASH),
    }

    name_to_variable::Union{
        Nothing,
        Dict{String, Union{Nothing, MOI.VariableIndex}},
    }
    enable_interrupts::Bool

    function Optimizer(env::Union{Nothing, LSenv} = nothing,
                       enable_interrupts::Bool = false,)

        model = new()
        model.ptr = C_NULL
        model.env = env === nothing ? Env() : env
        model.silent = false
        model.objective_type = _SCALAR_AFFINE
        model.objective_function = nothing
        model.objective_sense = MOI.MIN_SENSE
        model.lindoTerminationStatus = LS_STATUS_UNLOADED
        model.next_column = 1
        model.primal_values = Vector{Cdouble}(undef,0)
        model.primal_retrived = false
        model.nlp_count = 0
        model.variable_info = CleverDicts.CleverDict{MOI.VariableIndex,_VariableInfo}(
            _HASH,
            _INVERSE_HASH,
        )
        MOI.empty!(model)
        finalizer(model) do m
            ret = LSdeleteModel(m.ptr)
            _check_ret(m,ret)
            m.env.attached_models -= 1
            if env === nothing
                @assert m.env.attached_models == 0
                finalize(m.env)
            elseif m.env.finalize_called && m.env.attached_models == 0
                ret = LSdeleteEnv(m.env.ptr)
                _check_ret(m,ret)
                m.env.ptr = C_NULL
            end
        end
        return model
    end
end

# implement Base.cconvert
Base.cconvert(::Type{Ptr{Cvoid}}, model::Optimizer) = model
# implement Base.unsafe_convert
Base.unsafe_convert(::Type{Ptr{Cvoid}}, model::Optimizer) = model.ptr

function MOI.empty!(model::Optimizer)
    """
        Empty the model
    remove all variables, constraints, and model attributes,
    but not Optimizer attributes
    """
    if model.ptr != C_NULL
        ret = LSdeleteModel(model.ptr)
        _check_ret(model,ret)
        model.env.attached_models -= 1
    end

    ret = Int32[0]
    model.ptr  = LScreateModel(model.env, ret)
    _check_ret(model, ret[1])
    model.env.attached_models += 1
    model.next_column = 1
    model.name_to_variable = nothing
    model.primal_values = Vector{Cdouble}(undef,0)
    model.primal_retrived = false
    model.objective_type = _SCALAR_AFFINE
    model.objective_function = nothing
    model.objective_sense = MOI.MIN_SENSE
    empty!(model.variable_info)
end

function MOI.is_empty(model)
    """
        Returns false if the model has any
        variables, constraints, and model attributes
    """
    model.objective_type != _SCALAR_AFFINE && return false
    !isone(model.next_column) && return false
    return true
end

function _check_ret(model::Optimizer,ret::Int32)
    """
        Check for success after calling a C function
    If the return value is 0 the function was success
    Otherwise call LSgetErrorMessage to get the cause of error
    """
    if ret != 0
        pachMessage = Vector{UInt8}(undef, 64)
        LSgetErrorMessage(model.env, ret, pachMessage)
        error_string = unsafe_string(pointer(pachMessage))
        return error("Lindo API Error ==> $(error_string)")
    end
    return 0
end

# Short-cuts to return the _VariableInfo associated with an index.
function _info(model::Optimizer, key::MOI.VariableIndex)
    if haskey(model.variable_info, key)
        return model.variable_info[key]
    end
    return error(MOI.InvalidIndex(key))
end

function _add_to_expr_list(model::Optimizer,code, numval, ikod, ival, instructionList)
    for i in 1:length(instructionList)
        if typeof(instructionList[i]) == Cdouble
            code[ikod] = EP_PUSH_NUM;          ikod += 1;
            code[ikod] = ival - 1;             ikod += 1;
            numval[ival] = instructionList[i]; ival += 1;
        elseif typeof(instructionList[i]) == MathOptInterface.VariableIndex
            info = _info(model, instructionList[i])
            code[ikod] = EP_PUSH_VAR;          ikod += 1;
            code[ikod] = info.index.value - 1; ikod += 1;
        else
            code[ikod] = Sym_To_EP[instructionList[i]]; ikod += 1;
        end
    end
    return code, numval, ikod, ival
end

function _get_next_column(model::Optimizer)
    model.next_column += 1
    return model.next_column - 1
end

# Return the set objective function
MOI.get(model::Optimizer, ::MOI.AbstractFunction) = model.objective_function

function MOI.optimize!(model::Optimizer)

    init_feat = Symbol[:ExprGraph]
    MOI.initialize(model.nlp_data.evaluator, init_feat)
    con_count = length(model.nlp_data.constraint_bounds)
    # initilze list with some memory
    code = Vector{Cint}(undef, 200)
    numval = Vector{Cdouble}(undef, 30)
    lwrbnd = Vector{Cdouble}(undef, model.next_column - 1)
    uprbnd = Vector{Cdouble}(undef, model.next_column - 1)
    varval = Vector{Cdouble}(undef, model.next_column - 1)
    vtype = Vector{Cchar}(undef, model.next_column - 1)
    objsense = [LS_MIN] # TODO
    objs_beg = [0]
    objs_length = Vector{Int32}(undef,1)
    ctype = Vector{Cchar}(undef, con_count)
    cons_beg = Vector{Int32}(undef, con_count)
    cons_length = Vector{Int32}(undef, con_count)
    # list indexes
    ikod = 1 # instruction list
    ival = 1 # constants (numval) list
    iobj = 1
    icon = 1

    # Add Objective to argument lists
    instructionList = []
    child_count_list = []
    instructionList, child_count_list = get_pre_order(MOI.objective_expr(model.nlp_data.evaluator), instructionList, child_count_list)
    instructionList = pre_to_post(instructionList,child_count_list)
    code, numval, ikod, ival = _add_to_expr_list(model,code, numval, ikod, ival, instructionList)
    objs_length[iobj] = ikod - (objs_beg[iobj]+1)
    iobj += 1
    # Add Constraints to argument lists
    for i in 1:length(model.nlp_data.constraint_bounds)
        instructionList = []
        child_count_list = []
        instructionList, child_count_list = get_pre_order(MOI.constraint_expr(model.nlp_data.evaluator, i).args[2], instructionList, child_count_list)
        instructionList = pre_to_post(instructionList,child_count_list)
        ctype[icon] = _CON_TYPE[MOI.constraint_expr(model.nlp_data.evaluator, i).args[1]]
        cons_beg[icon] = ikod - 1
        code, numval, ikod, ival = _add_to_expr_list(model,code, numval, ikod, ival, instructionList)
        cons_length[icon] = ikod - (cons_beg[icon] + 1)
        icon += 1
    end

    # dummy lists until ability to add to variables
    for i in 1:(model.next_column - 1)
        lwrbnd[i] = -1e30
        uprbnd[i] = 1e30
        varval[i] = 1.0
        vtype[i] = 'C'
    end

    nvars = model.next_column - 1
    ncons = length(model.nlp_data.constraint_bounds)
    nobjs = 1
    lsize = ikod - 1
    ret = LSloadInstruct(model.ptr, ncons, nobjs, nvars, ival,
                 objsense, ctype,  vtype, code, lsize, C_NULL,
                 numval, varval, objs_beg, objs_length, cons_beg,
                 cons_length, lwrbnd, uprbnd)
    _check_ret(model, ret)
    pnStatus = Int32[-1]
    ret = LSoptimize(model.ptr, LS_METHOD_FREE, pnStatus)
    model.lindoTerminationStatus = pnStatus[1]
    _check_ret(model, ret)
    return
end

function MOI.get(model::Optimizer, attr::MOI.ObjectiveValue)
    dObj = Cdouble[-1]
    ret = LSgetInfo(model.ptr, LS_DINFO_POBJ, dObj)
    _check_ret(model, ret)
    return dObj[1]
end

# Since the Lindo API can only quary for
# all primal solution this a seprate function
# is written to only call LSgetPrimalSolution
# once for a model
function getPrimalSolution(model)
    nVars = model.next_column - 1
    resize!(model.primal_values, nVars)
    ret = LSgetPrimalSolution(model.ptr, model.primal_values)
    _check_ret(model, ret)
end

function MOI.get(model::Optimizer, attr::MOI.VariablePrimal, i::MOI.VariableIndex)
    if model.primal_retrived == false
        getPrimalSolution(model)
        model.primal_retrived = true
    end
    info = _info(model, i)
    return model.primal_values[info.column]
end

#=================================================================================
==================================================================================#
function Base.show(io::IO, model::Optimizer)
    """
        Prints a nice string when model is printed
    """
    return println(io, "Lindo API with the pointer $(model.ptr)")
end
#=================================================================================
Getters setters and Supports
==================================================================================#

# required supports
MOI.supports(model::Optimizer, ::MOI.SolverName) = true
MOI.supports(model::Optimizer, ::MOI.RawSolver) = true
MOI.supports(model::Optimizer, ::MOI.Name) = false
MOI.supports(model::Optimizer, ::MOI.Silent) = true
MOI.supports(model::Optimizer, ::MOI.TimeLimitSec) = false
MOI.supports(model::Optimizer, ::MOI.NumberOfThreads) = false
MOI.supports(model::Optimizer, ::MOI.NumberOfVariables) = true
MOI.supports(model::Optimizer, ::MOI.ObjectiveFunctionType) = true
MOI.supports(model::Optimizer, ::MOI.TerminationStatus) = true
MOI.supports(model::Optimizer, ::MOI.VariablePrimal, ::Type{MOI.VariableIndex}) = true
# required setters


function MOI.set(model::Optimizer, ::MOI.Silent, flag::Bool)
    model.silent = flag
    return
end

# required getterss
function MOI.get(model::Optimizer, attr::MOI.TerminationStatus)
    model.lindoTerminationStatus == LS_STATUS_OPTIMAL && return MOI.OPTIMAL
    model.lindoTerminationStatus == LS_STATUS_BASIC_OPTIMAL && return MOI.OPTIMAL
    model.lindoTerminationStatus == LS_STATUS_INFEASIBLE && returnMOI.INFEASIBLE
    model.lindoTerminationStatus == LS_STATUS_LOCAL_OPTIMAL && return MOI.LOCALLY_SOLVED
    model.lindoTerminationStatus == LS_STATUS_LOCAL_INFEASIBLE && return MOI.LOCALLY_INFEASIBLE
    model.lindoTerminationStatus == LS_STATUS_UNBOUNDED && return MOI.INFEASIBLE_OR_UNBOUNDED
    model.lindoTerminationStatus == LS_STATUS_INFEASIBLE && return MOI.INFEASIBLE_OR_UNBOUNDED
    return MOI.OPTIMIZE_NOT_CALLED
end

function MOI.get(model::Optimizer, ::MOI.Silent)
    return model.silent
end

"""Returns the name of the solver"""
MOI.get(model::Optimizer, ::MOI.SolverName) = "Lindo"

""" A model attribute for the object that may be used to access a solver-specific API for this optimizer. """
MOI.get(model::Optimizer, ::MOI.RawSolver) = model.ptr

"""  """
MOI.get(model::Optimizer, ::MOI.NumberOfVariables) = length(model.variable_info)

"""  """
function MOI.get(model::Optimizer, ::MOI.ObjectiveFunctionType)
    if model.objective_type == _SCALAR_AFFINE
        return MOI.ScalarAffineFunction{Float64}
    end
    return nothing
end

# objective_sense::MOI.ObjectiveSense
""" A model attribute for the objective sense of the objective function,
which must be an OptimizationSense: MIN_SENSE, MAX_SENSE, or FEASIBILITY_SENSE.
The default is FEASIBILITY_SENSE.
"""
MOI.supports(model::Optimizer, ::MOI.ObjectiveSense) = true # TODO: List off what sense it supports?

MOI.get(model::Optimizer, ::MOI.ObjectiveSense) = model.objective_sense

function MOI.set(model::Optimizer, ::MOI.ObjectiveSense, sense::MOI.OptimizationSense)
    model.objective_sense = sense
    return
end

function MOI.supports(model::Optimizer, ::MOI.ObjectiveFunction{F})where {F <: Union{MOI.ScalarAffineFunction{Float64}}} #TODO add more objective types
    return true
end


# Compatible Constraints

function MOI.supports_constraint(
    ::Optimizer, ::Type{MOI.ScalarAffineFunction{Float64}}, ::Type{F}
) where {F <: Union{
    MOI.EqualTo{Float64}, MOI.LessThan{Float64}, MOI.GreaterThan{Float64}
}}
    return true
end

MOI.supports(::Optimizer, ::MOI.NLPBlock) = true

function MOI.set(model::Optimizer, ::MOI.NLPBlock, nlp_data::MOI.NLPBlockData)
    model.nlp_data = nlp_data
end


include("MOI_expression_tree.jl")
include("MOI_var.jl")
include("supportedOperators.jl")
