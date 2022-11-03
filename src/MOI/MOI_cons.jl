#=

 File: MOI_cons.jl
 Brief: The functions in this file are used to add constraints
        to a MOI model.

 Authors: James Haas,

 Bugs:

=#


#=

 Function add_constraint in MOI.ScalarAffineFunction{Float64}
 Breif: Add one or more variables to a model.

 Param model:
 Param f::MOI.ScalarAffineFunction{Float64} 
        The scalar-valued affine function a'x
        f can be seperated into its terms (f.terms)
        Each term has a MOI.VariableIndex (term.variable) 
        and a coefficient (term.coefficient).

        s <: _CONS_ where _CONS_ are allowed constants
         == , <= and >=


 Return index: MOI.ConstraintIndex{typeof(f),typeof(s)}(row number)
=#
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
    # handel each type of constants
    if typeof(s) == MOI.LessThan{Float64}
        rhs = s.upper
        ctype = LS_CONTYPE_LE
    elseif typeof(s) == MOI.GreaterThan{Float64}
        rhs = s.lower
        ctype = LS_CONTYPE_GE
    else
        rhs = s.value
        ctype = LS_CONTYPE_EQ
    end
 
    
    data = _ScalarAffineConData(ctype, rhs, coeffs,vars)
    conInfo = _ConInfo(_SCALAR_AFFINE_CON, data)
    index = MOI.ConstraintIndex{typeof(f),typeof(s)}(model.next_row)
    model.con_info[index] = conInfo

    model.n_unloaded_cons += 1
    model.next_row += 1
    return  index
end


function MOI.add_constraint(model::Optimizer,
    f::MOI.ScalarQuadraticFunction{Float64},
    s::S
) where {S <: _CONS_}

    
    # make empty array for _ScalarQuadraticOBJData
    N_quad = length(f.quadratic_terms)
    N_affine = length(f.affine_terms) 
    quad_coeffs = Vector{Float64}(undef,N_quad)
    affine_coeffs = Vector{Float64}(undef,N_affine)
    quad_1_vars = Vector{MOI.VariableIndex}(undef,N_quad)
    quad_2_vars = Vector{MOI.VariableIndex}(undef,N_quad)
    affine_vars = Vector{MOI.VariableIndex}(undef,N_affine)

    # get quadratic terms loaded
    for (i, term) in enumerate(f.quadratic_terms)
        quad_coeffs[i] = term.coefficient
        quad_1_vars[i] = term.variable_1
        quad_2_vars[i] = term.variable_2
    end
    # get affine terms
    for (i, term) in enumerate(f.affine_terms)
        affine_coeffs[i] = term.coefficient 
        affine_vars[i] = term.variable 
    end
    # handel each type of constants
    if typeof(s) == MOI.LessThan{Float64}
        rhs = s.upper
        ctype = LS_CONTYPE_LE
    elseif typeof(s) == MOI.GreaterThan{Float64}
        rhs = s.lower
        ctype = LS_CONTYPE_GE
    else
        rhs = s.value
        ctype = LS_CONTYPE_EQ
    end

    constant = f.constant

    data = _ScalarQuadConData(ctype,rhs,quad_coeffs,affine_coeffs,
                              quad_1_vars,quad_2_vars,affine_vars,constant)
    conInfo = _ConInfo(_SCALAR_QUAD_CON, data)
    index = MOI.ConstraintIndex{typeof(f),typeof(s)}(model.next_row)
    model.con_info[index] = conInfo

    model.n_unloaded_cons += 1
    model.next_row += 1
    return  index
end