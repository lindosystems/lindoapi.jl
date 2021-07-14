

import MathOptInterface

const MOI = MathOptInterface
const CleverDicts = MOI.Utilities.CleverDicts
const _HASH = CleverDicts.key_to_index
const _INVERSE_HASH = x -> CleverDicts.index_to_key(MOI.VariableIndex, x)

const _SUPPORTED_OBJECTIVE_FUNCTION = Union{Nothing, MOI.AbstractFunction}

const _SUPPORTED_SCALAR_SETS =
    Union{MOI.GreaterThan{Float64},MOI.LessThan{Float64},MOI.EqualTo{Float64}}

const _SCALAR_SETS = Dict(
        MOI.GreaterThan{Float64} => LS_CONTYPE_GE,
        MOI.LessThan{Float64} => LS_CONTYPE_LE,
        MOI.EqualTo{Float64} => LS_CONTYPE_EQ,)

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

mutable struct _ConstraintInfo
    row::Int
    sence::Char
    coefficients::Vector{Cdouble}
    variables_index::Vector{Cint}
    b_row::Cdouble
    name::String

    function _ConstraintInfo(row::Int, sence::Char, coefficients::Vector{Cdouble}, variables_index::Vector{Cint}, b_row::Cdouble)
        constraint_info = new()
        constraint_info.row = row
        constraint_info.sence = sence
        constraint_info.coefficients = coefficients
        constraint_info.variables_index = variables_index
        constraint_info.b_row = b_row
        constraint_info.name = ""
        return constraint_info
    end
end

mutable struct Env
    ptr::Ptr{Cvoid}
    key::Vector{UInt8}
    pn_error_code::Vector{Int32}
    finalize_called::Bool

    function Env()
        # pszFname
        fn = "/opt/lindoapi/license/lndapi130.lic" #TODO fix where paths are defined
        key = Vector{UInt8}(undef, 1024)
        # LSloadLicenseString(pszFname, pachLicense)
        if LSloadLicenseString(fn, key) != 0
            error("Invalid License!")
            exit(0)
        end

        # ptr = LScreateEnv(pnErrorcode, pszPassword)
        pn_error_code = Int32[-1]
        ptr = LScreateEnv(pn_error_code, key)
        if pn_error_code[1] != 0
            error("Lindo Error $(pn_error_code[1]): Unable to create Lindo eviroment!")
            exit(0)
        end

        env = new(ptr, key, pn_error_code, false)

        finalizer(env) do e #TODO not sure how and where this is called
            e.finalize_called = true
            error_code = LSdeleteEnv(env.ptr)
            println("Error Code:  $(error_code)")
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

    env::Env
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
    objective_sense::MOI.OptimizationSense

    # Use to track the next variable
    next_column::Int
    # Use to track next constraint
    next_row::Int

    # Goal is to support LP
    # use affine_constraint_info to store each affine constraint
    affine_constraint_info::Dict{Int,_ConstraintInfo}
    nonzero_affine_coefs::Int
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

    function Optimizer(env::Union{Nothing, LSenv} = nothing)
        model = new()
        model.ptr = C_NULL
        model.env = env === nothing ? Env() : env
        model.silent = false
        model.objective_type = _SCALAR_AFFINE
        model.objective_function = nothing
        model.objective_sense = MOI.MIN_SENSE

        model.next_column = 1
        model.next_row = 1

        model.affine_constraint_info = Dict{Int,_ConstraintInfo}()
        model.nonzero_affine_coefs = 0

        model.variable_info = CleverDicts.CleverDict{MOI.VariableIndex,_VariableInfo}(
            _HASH,
            _INVERSE_HASH,
        )
        MOI.empty!(model)
        finalizer(model) do m
            # frees memort associated with the pointer
            return
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
    pn_error_code = Int32[0]
    model.ptr  = LScreateModel(model.env, pn_error_code)
    _check_ret(model, pn_error_code[1])
    model.objective_sense = MOI.MIN_SENSE

    model.next_column = 1
    model.next_row = 1
    model.nonzero_affine_coefs = 0

    model.name_to_variable = nothing

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

function _get_next_column(model::Optimizer)
    model.next_column += 1
    return model.next_column - 1
end

function _get_next_row(model::Optimizer)
    model.next_row += 1
    return model.next_row - 1
end

function MOI.add_variables(model::Optimizer, N::Int)
    """
        Add n scalar variables to the model, returning a vector of variable indices.
    """
    # initilize the _VariableIndex
    # add_item to actualy
    indices = Vector{MOI.VariableIndex}(undef, N)
    for i in 1:N
        # Initialize `_VariableInfo` with a dummy `VariableIndex` and a column,
        # because we need `add_item` to tell us what the `VariableIndex` is.
        index = CleverDicts.add_item(model.variable_info,_VariableInfo(MOI.VariableIndex(0), 0))
        info = _info(model, index)
        info.index = index
        info.column = _get_next_column(model)
        indices[i] = index
    end
    return indices
end

function _get_cols_coefs(model::Optimizer, f::MOI.ScalarAffineFunction{Float64}) #TODO make this generic
    len = length(f.terms)
    cols = Cint[]
    coef = Cdouble[]
    nonzero_count = 0
    for term in f.terms
        if term.coefficient != 0
            nonzero_count += 1
        end
        push!(cols, Cint(_info(model, term.variable_index).column - 1))
        push!(coef, Cdouble(term.coefficient))
    end
    return nonzero_count, cols, coef
end

# Since each sense has a diffrent atribute to get the right hand side
# Coefficients _sense_and_rhs is implemented for each the _SUPPORTED_SCALAR_SETS
_sense_and_rhs(s::MOI.LessThan{Float64}) = (_SCALAR_SETS[MOI.LessThan{Float64}], s.upper)
_sense_and_rhs(s::MOI.GreaterThan{Float64}) = (_SCALAR_SETS[MOI.GreaterThan{Float64}], s.lower)
_sense_and_rhs(s::MOI.EqualTo{Float64}) = (_SCALAR_SETS[MOI.EqualTo{Float64}], s.value)

# use this to track model.nonzero_affine_coefs
function update_nonzero_affine_coefs(model::Optimizer, nnz::Int)
    model.nonzero_affine_coefs += nnz
    return
end

function MOI.add_constraint(model::Optimizer, f::MOI.ScalarAffineFunction{Float64}, set::_SUPPORTED_SCALAR_SETS,)
""" Add one Scalar Affine constraint to the model
    f = MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0) --> x'c + 0.0
    set = _SUPPORTED_SCALAR_SETS(b) --> (=, >=, <=)
    b is the right-hand side coefficient.
"""
    row = _get_next_row(model)
    nonzero_count, cols, coef = _get_cols_coefs(model, f)
    update_nonzero_affine_coefs(model, nonzero_count)
    sence, b_row = _sense_and_rhs(set)
    # initialze the _ConstraintInfo type for the one constraint
    # _ConstraintInfo(row::Int, sence::Int8, coefficients::Vector{Cdouble}, variables_index::Vector{Cint}, b_row::Cdouble)
    constraint_info = _ConstraintInfo(row, sence, coef, cols, b_row)
    # Add to affine_constraint_info::Dict{Int,_ConstraintInfo}
    model.affine_constraint_info[row] = constraint_info
    return model.affine_constraint_info[row]
end

function MOI.set(model::Optimizer,
    O::MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}},                #TODO: make more genaric
    f::MOI.ScalarAffineFunction{Float64}, )
    # _ObjectiveInfo(objective_type::_ObjectiveType, objective_function::_SUPPORTED_Objective_Function)
    model.objective_type = _SCALAR_AFFINE
    model.objective_function = f
    return
end

# Return the set objective function
MOI.get(model::Optimizer, ::MOI.AbstractFunction) = model.objective_function
# _parse_objective will be a multiple dispatch function that take in
# an objective function and return the appropriate data for MOI.optimize!

#=================================================================================
Call to MOI.optimize! block
==================================================================================#

function _parse_objective(model::Optimizer, f::MOI.ScalarAffineFunction{Float64})
    scalar = f.constant
    nonzero_count, cols, coef = _get_cols_coefs(model,f)
    return scalar, cols, coef
end

function _parse_objective(model::Optimizer, f::Nothing)
    error("No Objective function set!!!")
end

function _parse_affine_constraints(model::Optimizer)
    nonzero = model.nonzero_affine_coefs
    m = model.next_row - 1
    n = model.next_column - 1

    acConTypes = Vector{Cchar}(undef, m)
    adB = Vector{Cdouble}(undef, m)
    adA = Vector{Cdouble}(undef, nonzero)
    anRowX = Vector{Int32}(undef,nonzero)
    anBegCol = Vector{Int32}(undef,n+1)
    posA = 1
    posBeg = 1
    foundBeg = false
    for i in 1:n
        foundBeg = false
        for j in 1:m
            A_ij = model.affine_constraint_info[j].coefficients[i]
            if  A_ij != 0
                adA[posA] = A_ij
                anRowX[posA] = j - 1
                if foundBeg == false
                    anBegCol[posBeg] = posA - 1
                    posBeg += 1
                    foundBeg = true
                end
                posA += 1
            end
        end
    end
    anBegCol[n+1] = nonzero

    for j in 1:m
        acConTypes[j] = model.affine_constraint_info[j].sence
        adB[j] = model.affine_constraint_info[j].b_row
    end
    return acConTypes, adA, adB, anRowX, anBegCol
end

function parse_variables(model::Optimizer)
    nCon = model.next_row - 1
    pdLower = Vector{Cdouble}(undef, nCon)
    pdUpper = Vector{Cdouble}(undef, nCon)
    count = 1
    for var_info in values(model.variable_info)
        pdLower[count] = var_info.lower_bound_bounded
        pdUpper[count] = var_info.upper_bound_bounded
        count += 1
    end
    return pdLower, pdUpper
end

function MOI.optimize!(model::Optimizer)
    """
        This function will orginize that data and make the call
    to the correct LSload(*)Data curently running LSloadLPData
    for proof of consept.
    """
    pModel = model.ptr
    nCons = model.next_row - 1
    nVars = model.next_column - 1
    dObjSense = _SENSE[model.objective_sense]

    dObjConst, cols, adC = _parse_objective(model, model.objective_function)
    acConTypes, adA, adB, anRowX, anBegCol = _parse_affine_constraints(model::Optimizer)
    pdLower, pdUpper = parse_variables(model::Optimizer)
    nNZ = model.nonzero_affine_coefs
    nDir = 1
    dObjConst = 0.0
    pnLenCol = C_NULL

    ret = LSloadLPData(model.ptr ,nCons,nVars,nDir,
                                 dObjConst,adC,adB,acConTypes,nNZ,anBegCol,
                                 pnLenCol,adA,anRowX,pdLower,pdUpper)
    _check_ret(model, ret)

    pnStatus = Int32[-1]
    ret = LSoptimize(model.ptr, LS_METHOD_FREE, pnStatus)

    _check_ret(model, ret)
    return
end

function MOI.get(model::Optimizer, attr::MOI.ObjectiveValue)
    dObj = Cdouble[-1]
    ret = LSgetInfo(model.ptr, LS_DINFO_POBJ, dObj)
    _check_ret(model, ret)
    return dObj
end

function MOI.get(model::Optimizer, attr::MOI.VariablePrimal)
    nVars = model.next_column - 1
    padPrimal = Vector{Cdouble}(undef, nVars)
    ret = LSgetPrimalSolution(model.ptr, padPrimal)
    _check_ret(model, ret)
    return padPrimal
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

# supports
MOI.supports(model::Optimizer, ::MOI.Silent) = true
MOI.supports(model::Optimizer, ::MOI.Name) = false
MOI.supports(model::Optimizer, ::MOI.TimeLimitSec) = false

function MOI.supports(model::Optimizer, ::MOI.ObjectiveFunction{F})where {F <: Union{MOI.ScalarAffineFunction{Float64}}} #TODO add more objective types
    return true
end

# getters, setters

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

"""Returns the name of the solver"""
MOI.get(model::Optimizer, ::MOI.SolverName) = "Lindo"

""" A model attribute for the object that may be used to access a solver-specific API for this optimizer. """
MOI.get(model::Optimizer, ::MOI.RawSolver) = model.ptr

function MOI.get(model::Optimizer, ::MOI.Silent)
    return model.silent
end

function MOI.set(model::Optimizer, ::MOI.Silent, flag::Bool)
    model.silent = flag
    return
end
