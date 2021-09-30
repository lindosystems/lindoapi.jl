#=

 File: MOI_wrapper.jl
 Brief: MathOptInterface NLP wraper for the LINDO API

 Authors: James Haas,
    MOI documenation:  https://jump.dev/MathOptInterface.jl/stable/
    Insperation from:  https://github.com/jump-dev/Gurobi.jl
                       https://github.com/jump-dev/Ipopt.jl

 Bugs:

=#
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

#=

 mutable struct: _VariableInfo
 Brief: A data type for storing variable data

 Param index: A type-safe wrapper for Int64 for use in referencing variables in
    a model. To allow for deletion, indices need not be consecutive.
 Param column: The _get_next_column(model) value when inserted
 Param bound: Attache bound type like >= <= // Not yet supported
 Param lower_bound_bounded: Attach a lower bound to variable // Not yet supported
 Param upper_bound_bounded: Attach an upper bound to variable // Not yet supported
 Param name: Attach name to vatiable // Not yet supported

=#
mutable struct _VariableInfo
    index::MOI.VariableIndex
    column::Int
    vtype::Char
    bound::_BoundType
    lower_bound_bounded::Float64
    upper_bound_bounded::Float64
    name::String
    #=

     Function: _VariableInfo
     Brief: Constructor for the type _VariableInfo
        non param data set to defulat values

     Param index
     Param column

    =#
    function _VariableInfo(index::MOI.VariableIndex, column::Int)
        variable_info = new(index, column)
        variable_info.index = index
        variable_info.column = column
        variable_info.vtype = 'C'
        variable_info.bound = _NONE
        variable_info.lower_bound_bounded = -typemax(Float64)
        variable_info.upper_bound_bounded = typemax(Float64)
        variable_info.name = ""
        return variable_info
    end
end

#=

 mutable struct: Env
 Brief: A data type for storing Lindo

 Param ptr: A pointer to Lindo enviroment.
 Param key: A vector of char that contains an indviduals Lindo API license key.
 Param finalize_called: A flag for determining if the enviroments deconstructor
                        has been called.
 Param attached_models: A integer to count the number of models attached
                        to an enviroment.

=#
mutable struct Env
    ptr::Ptr{Cvoid}
    key::Vector{UInt8}
    finalize_called::Bool
    attached_models::Int
    #=
     Function: Env
     Brief: a constructor and deconstructor for a Lindo API Enviroment
        Takes no arguments initalizing an enviromet through API calls
        and sets a finalize_called to false and attached_models to 0

     API Call LSloadLicenseString: To get users license for enviroment constuctor
     API Call LScreateEnv: Lindo API enviroment constructor
     API Call LSdeleteEnv:  Lindo API enviroment deconstructor


    =#
    function Env()
        fn = joinpath(PATH, "license/lndapi130.lic")
        key = Vector{UInt8}(undef, 1024)
        ret = LSloadLicenseString(fn, key)
        if ret != 0
            error("Key not found check key $(license_path)")
        end
        pn_error_code = Int32[-1]
        ptr = LScreateEnv(pn_error_code, key)
        if pn_error_code[1] != 0
            error("Lindo Error $(pn_error_code[1]): Unable to create Lindo eviroment!")
            exit(0)
        end

        env = new(ptr, key, false, 0)

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

#=
 mutable struct Optimizer: A subtype of MOI.AbstractOptimizer
 Brief: epresnets an instance of an optimization problem tied to the Lindo API.

 Param env: Of type Nothing before creation and then Env (see mutable struct Env)
 Pram ptr: Of type pLSmodel a Lindo data type to be model pointer argument
            for API calls.
 Param loaded: A flag to determin if model instructions have been loaded.
 Param use_LSsolveMIP: A flag to determin weather or not to use LSsolveMIP()
    set to true in MOI.add_constraint located in MOI_var.jl
 Prama nlp_data: A MOI struct that holds any nonliner objective or constraint
 Param load_index: Used as a cursor to the last nlp_data to be loaded into model
 Param objective_sense: To hold weater the model is to be Minimized or Maximized
 Param lindoTerminationStatus: Set LS_STATUS_UNLOADED be defult and udjusted once
                            the MOI calls the Optimizer.
 Param next_column: Used to track how many variables have been added.
 Param primal_values: Hold the primal values retrived from
                     an API call to LSgetPrimalSolution.
 Param primal_retrived: A flag initilized to false and set to true after
                        LSgetPrimalSolution has been called to avoid recalling.

 variable_info: Store model variable in type _VariableInfo in a CleverDict
              'A smart storage type for managing sequential objects with
               non-decreasing integer indices'

 Pram silent: set to true TODO: Add False option to provide a verbose solver printout
 Param objective_type: Curently just suppoting NLP instruction list TODO:
 Param objective_function: Curently just suppoting NLP instruction list TODO:

=#
mutable struct Optimizer <: MOI.AbstractOptimizer

    env::Union{Nothing,Env}
    ptr::pLSmodel
    loaded::Bool
    use_LSsolveMIP::Bool
    nlp_data::MOI.NLPBlockData
    load_index::Int
    objective_sense::MOI.OptimizationSense
    lindoTerminationStatus::Int
    next_column::Int
    primal_values::Vector{Cdouble}
    primal_retrived::Bool
    variable_info::CleverDicts.CleverDict{
        MOI.VariableIndex,
        _VariableInfo,
        typeof(_HASH),
        typeof(_INVERSE_HASH),
    }

    #enable_interrupts::Bool
    silent::Bool
    objective_type::_ObjectiveType
    objective_function::_SUPPORTED_OBJECTIVE_FUNCTION

    #=

     Function: Optimizer
     Brief: a constructor and deconstructor for a Optimizer type.
            The finalizer is never called by a user directly, but is implemented
            to tell julia how to remove the model.ptr and model.env that
            have direct interaction with the Lindo API.

     Param env: Optional if none is provided one will be created

    =#
    function Optimizer(env::Union{Nothing, LSenv} = nothing,)
        model = new()
        model.ptr = C_NULL
        model.env = env === nothing ? Env() : env
        model.silent = false
        model.objective_type = _SCALAR_AFFINE
        model.objective_function = nothing
        model.loaded = false
        model.use_LSsolveMIP = false
        model.load_index = 0
        model.objective_sense = MOI.MIN_SENSE
        model.lindoTerminationStatus = LS_STATUS_UNLOADED
        model.next_column = 1
        model.primal_values = Vector{Cdouble}(undef,0)
        model.primal_retrived = false
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

#=
 Function empty!:

=#
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
    model.primal_values = Vector{Cdouble}(undef,0)
    model.primal_retrived = false
    model.load_index = 0
    model.objective_type = _SCALAR_AFFINE
    model.objective_function = nothing
    model.loaded = false
    model.use_LSsolveMIP = false
    model.objective_sense = MOI.MIN_SENSE
    empty!(model.variable_info)
end

#=

 Function is_empty:
 Breif: Returns false if the model has any variables, constraints,
        and model attributes.

 Param model: Of type Optimizer

 TODO: Fill this function with test for each attibute to Optimizer object.
       Curently not called by any implemented function.
=#
function MOI.is_empty(model::Optimizer)
    !isone(model.next_column) && return false
    return true
end

#=
 Function _check_ret:
 Breif: Checks the return code from an API call throws an error and
        and displays the error string.

 Param model: Of type Optimizer
 Param ret: A value returned from an API call if not 0 then there is an error.
=#
function _check_ret(model::Optimizer,ret::Int32)
    if ret != 0
        pachMessage = Vector{UInt8}(undef, 64)
        LSgetErrorMessage(model.env, ret, pachMessage)
        error_string = unsafe_string(pointer(pachMessage))
        return error("Lindo API Error ==> $(error_string)")
    end
    return 0
end

#=

 Function: _info
 Breif: When you have a VariableIndex and want to get the _VariableInfo type
        stored at that location.

 Para model: Of type Optimizer
 Param key: Looks like this MathOptInterface.VariableIndex(i)

 Return variable: If there is a _VariableInfo type stored at key
                  it will be returned.
 Else Return error message stating key parameter is not valid.

=#
function _info(model::Optimizer, key::MOI.VariableIndex)
    if haskey(model.variable_info, key)
        variable = model.variable_info[key]
        return variable
    end
    return error(MOI.InvalidIndex(key))
end

#=

 Function: _add_to_expr_list
 Breif: takes an post order expresion and
        (1) adds it to a Lindo instruction list (code)
        (2) adds to the numval list that stores coefficents
        (3) updates cursors ikod and ival
 Param model:
 Param code: A Lindo instruction list that is beinf filled.
 Param numval: A vector to hold coefficents being loaded into API model.
 Param ikod: A cursor that holds the place of the next index to add to code vector.
 Param ival: A cursor that holds the place of the nex coefficent to add to numval.
 Param instructionList: A julia instruction list used to fill code and numval.

=#
function _add_to_expr_list(model::Optimizer,code, numval, ikod, ival, instructionList)
    for i in 1:length(instructionList)
        # when space starts to run low
        # double the length of the instruction
        # vectors.
        if ikod > length(code) - 1
            code = resize!(code, length(code)*2)
        end
        if ival > length(numval) - 1
            numval = resize!(numval, length(numval)*2)
        end
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

#=

 Function _get_next_column:
 Breif: This function is used to get the next_columnm and,
        incrament the model attribute next_column.

 Param model:
=#
function _get_next_column(model::Optimizer)
    model.next_column += 1
    return model.next_column - 1
end


#=
 Function _parse:
 Brief: takes the objective and constraints in the NLPBlock
        And builds the arguments for
        LSloadInstruct if the model has not been loaded
        LSaddInstruct if the model is being updated.

 Param model:
 Param load: A flag that indicates if the model has been loaded

 TODO: Change objsense = [LS_MIN] to Change objsense = [LS_MIN]
 TODO: Fill lwrbnd[i], uprbnd[i], varval[i], vtype[i]
       With values attached to variable.

=#
function _parse(model::Optimizer,load::Bool)
    con_count = length(model.nlp_data.constraint_bounds)
    # initilze list with some memory
    code = Vector{Cint}(undef, 200)
    numval = Vector{Cdouble}(undef, 30)
    lwrbnd = Vector{Cdouble}(undef, model.next_column - 1)
    uprbnd = Vector{Cdouble}(undef, model.next_column - 1)
    varval = Vector{Cdouble}(undef,  model.next_column - 1)
    vtype = Vector{Cchar}(undef, model.next_column - 1)
    objsense = [_get_Lindo_sense(model)]
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
    if load
        instructionList = []
        child_count_list = []
        instructionList, child_count_list = get_pre_order(MOI.objective_expr(model.nlp_data.evaluator), instructionList, child_count_list)
        instructionList = pre_to_post(instructionList,child_count_list)
        code, numval, ikod, ival = _add_to_expr_list(model, code, numval, ikod, ival, instructionList)
        objs_length[iobj] = ikod - (objs_beg[iobj]+1)
        iobj += 1
    end

    # Add Constraints to argument lists
    # starting from the first to last unloaded constraint
    for i in (model.load_index+1):length(model.nlp_data.constraint_bounds)
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

    for (key, info) in model.variable_info
        lwrbnd[info.column] = info.lower_bound_bounded
        uprbnd[info.column] =info.upper_bound_bounded
        varval[info.column] = 1.0
        vtype[info.column] = info.vtype
    end

    ncons = length(model.nlp_data.constraint_bounds) - model.load_index
    model.load_index = length(model.nlp_data.constraint_bounds)
    nvars = model.next_column - 1
    lsize = ikod - 1
    if load
        nobjs = 1
        ret = LSloadInstruct(model.ptr, ncons, nobjs, nvars, ival,
                     objsense, ctype,  vtype, code, lsize, C_NULL,
                     numval, varval, objs_beg, objs_length, cons_beg,
                     cons_length, lwrbnd, uprbnd)
        _check_ret(model, ret)
    else
        nobjs = 0
        ret = LSaddInstruct(model.ptr, ncons, nobjs, nvars, ival,
                     objsense, ctype,  vtype, code, lsize, C_NULL,
                     numval, varval, objs_beg, objs_length, cons_beg,
                     cons_length, lwrbnd, uprbnd)
        _check_ret(model, ret)
    end
end

#=

 Function MOI.optimize!:

 Brief: Loads instructions to model then calls LSsolveMIP if there are any Bin or Int
        variables otherwise LSoptimize
        updates model.lindoTerminationStatus

=#
function MOI.optimize!(model::Optimizer)

    if model.loaded == false
        init_feat = Symbol[:ExprGraph]
        MOI.initialize(model.nlp_data.evaluator, init_feat)
        _parse(model, true)
        model.loaded = true
    elseif length(model.nlp_data.constraint_bounds) > model.load_index          # Add more constraints
        init_feat = Symbol[:ExprGraph]                                          # Init expresion graph access
        MOI.initialize(model.nlp_data.evaluator, init_feat)
        _parse(model, false)                                                    # Parse added constraints
        model.primal_retrived = false                                           # Set primal retrived set to false
    else                                                                        # to get the new primal variables
        nothing
    end
    pnStatus = Int32[-1]
    if model.use_LSsolveMIP == true
        ret = LSsolveMIP(model.ptr, pnStatus)
    else
        ret = LSoptimize(model.ptr, LS_METHOD_FREE, pnStatus)
    end
    _check_ret(model, ret)
    model.lindoTerminationStatus = pnStatus[1]
    return
end

#=

 Function MOI.get: // MOI.ObjectiveValue
 Brief: Gets the objective value by calling LSgetInfo
        errors handeled by _check_ret. The variable flag
        is determined based on if the MIP solver was used or not.

 Param model:
 Param attar: Sending MOI.SolverName() will let the MOI know what getter is being called.

 Returns: the models objective value.

=#
function MOI.get(model::Optimizer, attr::MOI.ObjectiveValue)
    flag = LS_DINFO_POBJ
    if model.use_LSsolveMIP == true
        flag = LS_DINFO_MIP_OBJ
    end
    dObj = Cdouble[-1]
    ret = LSgetInfo(model.ptr, flag, dObj)
    _check_ret(model, ret)
    return dObj[1]
end


#=

 Function getPrimalSolution:
 Breif: Since the Lindo API can only quary for
        all primal solution this a seprate function
        is written to only call LSgetPrimalSolution (or LSgetMIPPrimalSolution if MIP )
        once for a model. The values will be stored
        in the model at model.primal_values

 Param model:

=#
function _getPrimalSolution(model::Optimizer)
    nVars = model.next_column - 1
    resize!(model.primal_values, nVars)
    if model.use_LSsolveMIP == true
        ret = LSgetMIPPrimalSolution(model.ptr, model.primal_values)
    else
        ret = LSgetPrimalSolution(model.ptr, model.primal_values)
    end

    _check_ret(model, ret)
end

#=
LSgetMIPPrimalSolution( pModel, primal)
 Function MOI.get // attr::MOI.VariablePrimal
 Breif: gets the primal value of variable at given index.

 Param model:
 Param attr: This idicates what MOI.get function to call put MOI.VariablePrimal()
             In as for argument when directly calling.
 Param key: A MOI.VariableIndex that needs to be retrived

=#
function MOI.get(model::Optimizer, attr::MOI.VariablePrimal, key::MOI.VariableIndex)
    # if there primal has not been saved to the model
    if model.primal_retrived == false
        _getPrimalSolution(model)
        model.primal_retrived = true
    end
    # to the index where the variable is stored
    info = _info(model, key)
    return model.primal_values[info.column]
end

#=

Function: Base.show
Brief: Called bayed Julia when model is crated in REPL
        or when the @show macro is used when model is crated.
        Prints a nice string when model is printed.

 Param io: Input Output Buffer
 Param model:

 Returns: The print statement.

=#
function Base.show(io::IO, model::Optimizer)
    return println(io, "Lindo API with the pointer $(model.ptr)")
end

#=

 Function: MOI.supports

 Returns: True if the MOI wrapper Supports an attributes
          Flase if not.

=#
MOI.supports(model::Optimizer, ::MOI.SolverName) = true
MOI.supports(model::Optimizer, ::MOI.RawSolver) = true
MOI.supports(model::Optimizer, ::MOI.Name) = false
MOI.supports(model::Optimizer, ::MOI.Silent) = true
MOI.supports(model::Optimizer, ::MOI.TimeLimitSec) = false
MOI.supports(model::Optimizer, ::MOI.NumberOfThreads) = false
MOI.supports(model::Optimizer, ::MOI.NumberOfVariables) = true
MOI.supports(model::Optimizer, ::MOI.TerminationStatus) = true
MOI.supports(model::Optimizer, ::MOI.VariablePrimal, ::Type{MOI.VariableIndex}) = true
MOI.supports(model::Optimizer, ::MOI.ObjectiveSense) = true
MOI.supports(::Optimizer, ::MOI.NLPBlock) = true


#=

 Function: MOI.supports_constraint

 Breif: This funciton is called by the interface when a constraint on
    a variable is added.

Exsample: From JuMP @variable(model, x, Int) this will MOI.add_variables to
        initilze variable then MOI.add_constraint to add the integer constraint

 Returns: True if the MOI wrapper Supports a constraint
          Flase if not.
=#
function MOI.supports_constraint( ::Optimizer, ::Type{MOI.SingleVariable},
    ::Type{F}) where {
                F<:Union{
                        MOI.ZeroOne,
                        MOI.Integer,
                        MOI.LessThan{Float64},
                        MOI.GreaterThan{Float64},
                        MOI.Interval{Float64},
                        }
                      }
    return true
end

# Return the set objective function
MOI.get(model::Optimizer, ::MOI.AbstractFunction) = model.objective_function

#=

 Function MOI.get: // MOI.Silent
 Breif:

 Param model:
 Param : Sending MOI.Silent() will let the MOI know what getter is being called.

=#
function MOI.set(model::Optimizer, ::MOI.Silent, flag::Bool)
    model.silent = flag
    return
end

#=

 Function MOI.get: // MOI.Silent

 Param model:
 Param : Sending MOI.Silent() will let the MOI know what getter is being called.

 Returns: The boolen value stored in model.silent

=#
function MOI.get(model::Optimizer, ::MOI.Silent)
    return model.silent
end

#=

 Function: MOI.get // MOI.TerminationStatus
 Breif: Turns Lindo API model's termination status into an equivalent
        MOI termination status and returns it.

 Params model:
 Param attr: If calling directly send MOI.TerminationStatus() as argument.

 Returns: MOI tremination status.

=#
function MOI.get(model::Optimizer, attr::MOI.TerminationStatus)
    model.lindoTerminationStatus == LS_STATUS_OPTIMAL && return MOI.OPTIMAL
    model.lindoTerminationStatus == LS_STATUS_BASIC_OPTIMAL && return MOI.OPTIMAL
    model.lindoTerminationStatus == LS_STATUS_INFEASIBLE && return MOI.INFEASIBLE
    model.lindoTerminationStatus == LS_STATUS_LOCAL_OPTIMAL && return MOI.LOCALLY_SOLVED
    model.lindoTerminationStatus == LS_STATUS_LOCAL_INFEASIBLE && return MOI.LOCALLY_INFEASIBLE
    model.lindoTerminationStatus == LS_STATUS_UNBOUNDED && return MOI.DUAL_INFEASIBLE
    model.lindoTerminationStatus == LS_STATUS_INFEASIBLE && return MOI.INFEASIBLE_OR_UNBOUNDED
    return MOI.OPTIMIZE_NOT_CALLED
end

#=

 Function MOI.get: // MOI.SolverName

 Param model:
 Param : Sending MOI.SolverName() will let the MOI know what getter is being called.

 Returns: The string "Lindo".

=#
MOI.get(model::Optimizer, ::MOI.SolverName) = "Lindo"

#=

 Function MOI.get: // MOI.RawSolver

 Param model:
 Param : Sending MOI.RawSolver() will let the MOI know what getter is being called.

 Returns: The model pointer.

=#
MOI.get(model::Optimizer, ::MOI.RawSolver) = model.ptr

#=

 Function MOI.get: // MOI.NumberOfVariables

 Param model:
 Param : Sending MOI.NumberOfVariables() will let the MOI know what getter is being called.

 Returns: The number of variables attached to model.

=#
MOI.get(model::Optimizer, ::MOI.NumberOfVariables) = length(model.variable_info)

#=

 Function MOI.get: // MOI.ObjectiveSense

 Param model:
 Param : Sending MOI.ObjectiveSense() will let the MOI know what getter is being called.

 Returns: The objective sense attached to the model.

=#
MOI.get(model::Optimizer, ::MOI.ObjectiveSense) = model.objective_sense

#=

 Function MOI.set: // MOI.ObjectiveSense

 Param model:
 Param : Sending MOI.ObjectiveSense() will let the MOI know what setter is being called.

 Returns: The objective sense attached to the model.

=#
function MOI.set(model::Optimizer, ::MOI.ObjectiveSense, sense::MOI.OptimizationSense)
    model.objective_sense = sense
    return
end

#=

 Function _get_Lindo_sense()

 Param model:

 Returns: The objective sense attached to model
          converted into the proper Lindo flag

=#
_get_Lindo_sense(model::Optimizer) = _SENSE[model.objective_sense]

#=

 Function MOI.set: // MOI.NLPBlock

 Breif: Attaches the NLPBlock struct to the model

 Param model:
 Param : Sending MOI.NLPBlock() will let the MOI know what setter is being called.
 Param nlp_data: The nlp_data to be attached to the model

 Returns: The objective sense attached to the model.

=#
function MOI.set(model::Optimizer, ::MOI.NLPBlock, nlp_data::MOI.NLPBlockData)
    model.nlp_data = nlp_data
end

#=

 Detcahed MOI_wrapper related code
 to make it more manageable

=#
include("MOI_expression_tree.jl")
include("MOI_var.jl")
include("supportedOperators.jl")
