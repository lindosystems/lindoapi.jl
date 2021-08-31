# MathOptInterface :ExprGraph

# Recursively travers a julia Expr that is stored in pre-order
function get_pre_order(expr::Expr, instructionList, child_count_list)
    for i in 1:length(expr.args)
        if typeof(expr.args[i]) == Expr && typeof(expr.args[i].args[2]) == MathOptInterface.VariableIndex
            push!(child_count_list , 0)
            push!(instructionList, expr.args[i].args[2])
        elseif typeof(expr.args[i]) != Symbol && typeof(expr.args[i]) != Expr
            push!(child_count_list , 0)
            push!(instructionList, expr.args[i])
        elseif typeof(expr.args[i]) == Symbol && typeof(expr.args[i]) != Expr
            push!(child_count_list , length(expr.args) - 1)
            push!(instructionList, expr.args[i])
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
