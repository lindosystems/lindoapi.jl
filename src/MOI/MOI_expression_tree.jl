#=

 File: MOI_expression_tree.jl
 Brief: The functions in this file are used to convert
      the expresion tree from the NLPBlock of type Expr to an
      instruction list that is in post order for the Lindo API.

 Authors: James Haas,

 Bugs:

=#

#=

 Function get_pre_order:
 Breif: Recursivly traverses an expr of type Expr to get a
       pre-order treversal of an expression tree.

 Param expr: A expresion list from the NLPBlock.
 Param instructionList: An empty list to hold the pre-order traversal.
 Param child_count_list: An empty list to hold the number of childern each node has.
      used for converting to post-order.

 Return instructionList:

=#
function get_pre_order(expr::Expr, instructionList, child_count_list)
    for i in 1:length(expr.args)
        if typeof(expr.args[i]) == Expr && typeof(expr.args[i].args[2]) == MathOptInterface.VariableIndex
            push!(child_count_list , 0)
            push!(instructionList, expr.args[i].args[2])
        elseif typeof(expr.args[i]) != Symbol && typeof(expr.args[i]) != Expr
            push!(child_count_list , 0)
            push!(instructionList, expr.args[i])
        elseif typeof(expr.args[i]) == Symbol && typeof(expr.args[i]) != Expr
            # An operator can not have more then 2 childern
            # If it has length(expr.args) - 1 = 3 it should be two repeted operators
            child_count = length(expr.args) - 1
            if child_count == 1 && expr.args[i] == :-
                # if -x then change to * -1 x

                push!(child_count_list , 2)
                push!(instructionList, :*)
                push!(child_count_list , 0)
                push!(instructionList, -1.0)
            elseif child_count <= 2
                push!(child_count_list , child_count)
                push!(instructionList, expr.args[i])
            else
                for k in 2:child_count
                    push!(child_count_list , 2)
                    push!(instructionList, expr.args[i])
                end
            end
        else
            get_pre_order(expr.args[i], instructionList, child_count_list )
        end
    end
    return instructionList, child_count_list
end

# Convert a pre-order list into a post order list
# this approch uses a stack to hold the nodes while finding the leaves
# pop_count is a list that tracks how many children of a node have been popped
#
# Arguments:
# pre_list: pre-order traversal list
# child_count_list: the number of childern that a node has
#
# Output:
# post_list: Converted from the pre-order traversal list


function pre_to_post(pre_list, child_count_list)
    pre_stack = Vector{Any}(undef, length(pre_list))
    pop_count = Vector{Int8}(undef, length(pre_list))
    post_list = Vector{Any}(undef, length(pre_list))
    # intilize positions
    pre_list_pos = 1
    post_list_pos = 1
    stack_pos = 1
    # add the root of the expression tree to stack
    pre_stack[1] = pre_list[1]
    pop_count[1] = child_count_list[1]

    while stack_pos > 0
        # If in the last iteration the pop count of
        # the top of the stack became 0 it must be removed
        if pop_count[stack_pos] == 0
            # add to post list
            post_list[post_list_pos] = pre_stack[stack_pos]
            post_list_pos  += 1
            # pop off stack
            stack_pos -= 1
            # fails when the only thing left is the root
            if stack_pos > 0
                pop_count[stack_pos] -= 1
            end
        else
            # push to stack
            pre_list_pos += 1
            stack_pos += 1
            pre_stack[stack_pos] = pre_list[pre_list_pos]
            pop_count[stack_pos] = child_count_list[pre_list_pos]
            # this will be true when an operand is added to stack
            if pop_count[stack_pos] == 0
                # pop operand from the stack
                post_list[post_list_pos] = pre_stack[stack_pos]
                post_list_pos += 1
                stack_pos -= 1
                # deincrement pop count of operands parent
                pop_count[stack_pos] -= 1
            end
        end
    end
    return post_list
end


#=

 Function linear_to_post:
 Breif: build a post order instructionList for a linear funciton a'x
    can be constraint or objective. 

 Param instructionList: An empty list to hold the post-order traversal.
 Param vars: An array of MOI.VariableIndex "x"
 Param coeffs: An array of floats "a"



 Return instructionList:

=#
function linear_to_post(instructionList, vars, coeffs, is_obj=true, rhs=0.0 )
    pos = 1
    for i in eachindex(vars)
        instructionList[pos] = coeffs[i] ; pos += 1
        instructionList[pos] = vars[i]   ; pos += 1
        instructionList[pos] = :*        ; pos += 1
        if i >= 2
            instructionList[pos] = :+ ; pos += 1
        end
    end

    if is_obj == false
        instructionList[pos] = rhs ; pos += 1
        instructionList[pos] = :- 
    end

    return instructionList
end

#=

 Function var_obj_to_post:
 Breif: build a post order instructionList for an objective x
     
 Param instructionList: An empty list to hold the post-order traversal.
 Param vars: A MOI.VariableIndex "x"

 Return instructionList:

=#
function  var_obj_to_post(instructionList, vars )
    instructionList[1] = vars[1]
    return instructionList
end

#=

 Function quad_obj_post:
 Breif: build a post order instructionList for a function 1/2 x'Qx + a'x + b 
    can be constraint or objective.

 Param instructionList: An empty list to hold the post-order traversal.
 Paran quad_coeffs    A vector of coefficents in the quadratic part "Q"
 Paran affine_coeffs  A vector of coefficents in the affine part "a"
 Paran quad_1_vars    The first vector of variables in the quadratic part
 Paran quad_2_vars    The second vector of variables in the quadratic part
 Paran affine_vars    A vector of variable in the affine part
 Paran constant       A scalar constant `b`
 Paran is_obj         True if the objective function is being turned into an instruction list
 Paran rhs            Required for constraints, and is the right hand side of constraint 
 Return instructionList:

=#
function quad_to_post(instructionList, quad_coeffs,affine_coeffs,
                                           quad_1_vars,quad_2_vars,
                                           affine_vars, constant, is_obj=true, rhs=0.0)
    pos = 1
    instructionList[pos] = 0.5 ; pos += 1
    for i in eachindex(quad_coeffs)
        instructionList[pos] = quad_coeffs[i] ; pos += 1
        instructionList[pos] = quad_1_vars[i] ; pos += 1
        instructionList[pos] = :*             ; pos += 1
        instructionList[pos] = quad_2_vars[i] ; pos += 1
        instructionList[pos] = :*             ; pos += 1
        if i >= 2
            instructionList[pos] = :+ ; pos += 1
        end
    end

    instructionList[pos] = :* ; pos += 1

    
    if(length(affine_coeffs) > 0)
        for i in eachindex(affine_coeffs)
            instructionList[pos] = affine_coeffs[i] ; pos += 1
            instructionList[pos] = affine_vars[i]   ; pos += 1
            instructionList[pos] = :*        ; pos += 1
            instructionList[pos] = :+ ; pos += 1
        end
    end
    
    if is_obj 
        instructionList[pos] = constant ; pos += 1
        instructionList[pos] = :+ ; pos += 1
    else
        instructionList[pos] = constant - rhs ; pos += 1
        instructionList[pos] = :+
    end

    return instructionList
end






