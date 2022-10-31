#=

 File: MOI_obj.jl
 Brief: The functions in this file are used to parse and store 
        the models objective function. 

 Authors: James Haas,

 Bugs:

=#

#=

 Function set
 Brief: Sets MOI.ObjectiveFunction of type MOI.ScalarAffineFunction
 
=#
function MOI.set(
    model::Optimizer,
    t::MOI.ObjectiveFunction{F},
    f::F,
) where {F<:MOI.ScalarAffineFunction{Float64}}

    # Parse f to get coeffs and vars
    N = length(f.terms)
    coeffs = Vector{Float64}(undef,N)
    vars = Vector{MOI.VariableIndex}(undef,N)
    for (i, term) in enumerate(f.terms)
        coeffs[i] = term.coefficient
        vars[i] = term.variable
    end
    # create a _ScalarAffineOBJData data type to hold objective data
    data = _ScalarAffineOBJData(coeffs, vars)
    # fill in model.objective 
    model.objective.data = data
    model.objective.type = _SCALAR_AFFINE
    model.objective.isSet = true
    
    return
end

#=

 Function is_empty:
 Brief: Returns false if the model has any variables, constraints,
        and model attributes.

 Param model: Of type Optimizer

 TODO: Fill this function with test for each attibute to Optimizer object.
       Curently not called by any implemented function.
=#
function MOI.set(
    model::Optimizer,
    t::MOI.ObjectiveFunction{F},
    f::F,
) where {F<:MOI.ScalarQuadraticFunction{Float64}}

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

    constant = f.constant
    # create a _ScalarQuadraticOBJData data type to hold objective data
    data = _ScalarQuadraticOBJData(quad_coeffs,affine_coeffs,
                                   quad_1_vars,quad_2_vars,
                                   affine_vars,constant)
    # fill in model.objective 
    model.objective.data = data
    model.objective.type = _SCALAR_QUADRATIC
    model.objective.isSet = true                        
    
    return
end