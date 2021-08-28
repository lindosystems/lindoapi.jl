# MathOptInterface :ExprGraph

function get_pre_order(expr::Expr, instructionList, nodeLenList)
    for i in 1:length(expr.args)
        if typeof(expr.args[i]) == Expr && typeof(expr.args[i].args[2]) == MathOptInterface.VariableIndex
            push!(nodeLenList, 0)
            push!(instructionList, expr.args[i].args[2])
        elseif typeof(expr.args[i]) != Symbol && typeof(expr.args[i]) != Expr
            push!(nodeLenList, 0)
            push!(instructionList, expr.args[i])
        elseif typeof(expr.args[i]) == Symbol && typeof(expr.args[i]) != Expr
            push!(nodeLenList, length(expr.args) - 1)
            push!(instructionList, expr.args[i])
        else
            get_pre_order(expr.args[i], instructionList, nodeLenList)
        end
    end
    return instructionList, nodeLenList
end


function pre_to_post(pre_list)

    nlr_stack = Vector{Any}(undef, length(pre_list))
    pop_count = Vector{Int8}(undef, length(pre_list))
    post_list = Vector{Any}(undef, length(pre_list))
    pre_list_pos = 1
    post_list_pos = 1
    stack_pos = 1

    nlr_stack[1] = pre_list[1]
    pop_count[1] = 0
    while stack_pos > 0
        if pop_count[stack_pos] == 2
            post_list[post_list_pos] = nlr_stack[stack_pos]
            post_list_pos  += 1
            stack_pos -= 1
            if stack_pos > 0
                pop_count[stack_pos] += 1
            end
        else
            pre_list_pos += 1
            stack_pos += 1
            nlr_stack[stack_pos] = pre_list[pre_list_pos]
            pop_count[stack_pos] = 0
            if typeof(nlr_stack[stack_pos]) != Symbol
                post_list[post_list_pos] = nlr_stack[stack_pos]
                post_list_pos += 1
                stack_pos -= 1
                pop_count[stack_pos] += 1
            end
        end
    end
    return post_list
end
