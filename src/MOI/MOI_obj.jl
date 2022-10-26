function MOI.set(
    model::Optimizer,
    t::MOI.ObjectiveFunction{F},
    f::F,
) where {F<:_OBJ_}

    N = length(f.terms)
    coeffs = Vector{Float64}(undef,N)
    vars = Vector{MOI.VariableIndex}(undef,N)

    for (i, term) in enumerate(f.terms)
        coeffs[i] = term.coefficient
        vars[i] = term.variable
    end

    model.objective.coeffs = coeffs
    model.objective.vars = vars

    if typeof(t) == MathOptInterface.ObjectiveFunction{MathOptInterface.ScalarAffineFunction{Float64}}
        model.objective.type = _SCALAR_AFFINE 
    else
        model.objective.type = _VAR_INDEX
    end 

    model.objective.isSet = true
    
    return
end