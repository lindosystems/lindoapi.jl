#=

 File: MOI_var.jl
 Brief: The functions in this file are used to crate variables

 Authors: James Haas,

 Bugs:

 TODO: Implement MOI.add_constraint().
       To attach a constraint to a variable JuMP calls MOI.add_constraint().
       The data sent to this function could then be attached to the variables data
       see _VariableInfo.

=#

#=

 Function add_variables:
 Breif: Add one or more variables to a model.

 Param model:
 Param N: number of variables to add.

 Return indices: an array of MOI.VariableIndex

=#
function MOI.add_variables(model::Optimizer, N::Int)
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

#=

 Function  MOI.add_constraint
 Brief: This MOI.add_constraint is used to make a variable
        Binary or Integer

 Exsample: Called by JuMP when @variable(model, x, Int) is used

 Param model :
 Param f     : Has the variable index that is needed to fetch the
               variable constraint is being added to.
 Param Set   : Can be MOI.ZeroOne or MOI.Integer and is used to avoid
            wrtitng two funtions.

 Returns: ConstraintIndex

=#
function MOI.add_constraint(model::Optimizer,
    f::MOI.SingleVariable,
    s::Set
) where{Set <: Union{MOI.ZeroOne, MOI.Integer}}
    model.use_LSsolveMIP = true
    info = _info(model, f.variable)

    if typeof(s) == MOI.ZeroOne
        info.vtype = 'B'
    else
        info.vtype = 'I'
    end
    return MOI.ConstraintIndex{MOI.SingleVariable,typeof(s)}(f.variable.value)
end

#=

 Function  MOI.add_constraint
 Brief: This MOI.add_constraint is used to bound a variable

 Exsample: Called by JuMP when @variable(model, x >= 0) is used

 Param model :
 Param f     : Has the variable index that is needed to fetch the
               variable constraint is being added to.
 Param Set   : Can be MOI.LessThan, MOI.GreaterThan or MOI.Interval
               and is used to avoid wrtitng more then one funtions

 Returns: ConstraintIndex
=#
function MOI.add_constraint(model::Optimizer,
    f::MOI.SingleVariable,
    s::Set
) where{Set <: Union{MOI.LessThan{Float64},MOI.GreaterThan{Float64},MOI.Interval{Float64}}}
    info = _info(model, f.variable)
    if typeof(s) == MOI.LessThan{Float64}
        info.upper_bound_bounded = s.upper
    elseif typeof(s) == MOI.GreaterThan{Float64}
        info.lower_bound_bounded = s.lower
    else
        info.lower_bound_bounded = s.lower
        info.upper_bound_bounded = s.upper
    end

    return MOI.ConstraintIndex{MOI.SingleVariable,typeof(s)}(f.variable.value)
end
