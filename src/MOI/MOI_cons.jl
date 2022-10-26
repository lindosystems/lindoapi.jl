
function MOI.add_constraint(model::Optimizer,
                            f::MOI.ScalarAffineFunction{Float64},
                            s::S
) where {S <: _CONS_}

    # make a vector of VariableIndex
    # fill a vector of coefficients
    N = length(f.terms)
    coeffs = Vector{Float64}(undef,N)
    vars = Vector{MOI.VariableIndex}(undef,N)

    for (i, term) in enumerate(f.terms)
        coeffs[i] = term.coefficient
        vars[i] = term.variable
    end


    # println(coeffs)
    # println(vars)
    # println("-------------")
    # make the index
    index = MOI.ConstraintIndex{typeof(f),typeof(s)}(model.next_row)
    # add to dict 
    conInfo = _ScalarAffineConInfo(index)
    conInfo.ftype  = _SCALAR_AFFINE_CON
    conInfo.coeffs = coeffs
    conInfo.vars   = vars 
    model.n_unloaded_LP_cons += 1
    # handel each type of constants
    if typeof(s) == MOI.LessThan{Float64}
        conInfo.rhs = s.upper
        conInfo.ctype = LS_CONTYPE_LE
    elseif typeof(s) == MOI.GreaterThan{Float64}
        conInfo.rhs = s.lower
        conInfo.ctype = LS_CONTYPE_GE
    else
        conInfo.rhs = s.value
        conInfo.ctype = LS_CONTYPE_EQ
    end

    model.ScalarAffineCon_info[index] = conInfo
    model.next_row += 1
    #return .. 
    return  index
end