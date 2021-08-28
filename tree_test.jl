
# Convert a pre-order list into a post order list
# this approch uses a stack to hold the nodes while finding the leaves
# pop_count is a list that tracks how many children of a node have been popped
# once two childern have been popped the node is then poped
function pre_to_post(pre_list, children_list)

    pre_stack = Vector{Any}(undef, length(pre_list))
    pop_count = Vector{Int8}(undef, length(pre_list))
    post_list = Vector{Any}(undef, length(pre_list))
    pre_list_pos = 1
    post_list_pos = 1
    stack_pos = 1

    pre_stack[1] = pre_list[1]
    pop_count[1] = children_list[1]
    while stack_pos > 0
        
        if pop_count[stack_pos] == 0
            post_list[post_list_pos] = pre_stack[stack_pos]
            post_list_pos  += 1
            stack_pos -= 1
            if stack_pos > 0
                pop_count[stack_pos] -= 1
            end
        else
            # push
            pre_list_pos += 1
            stack_pos += 1
            pre_stack[stack_pos] = pre_list[pre_list_pos]
            pop_count[stack_pos] = children_list[pre_list_pos]

            if pop_count[stack_pos] == 0
                post_list[post_list_pos] = pre_stack[stack_pos]
                post_list_pos += 1
                stack_pos -= 1
                pop_count[stack_pos] -= 1
            end
        end
    end
    println(post_list)
end


pre_list = [:-, :+, :/, 1, 2, :^, 3, 2, 0]
children_list = [2, 2, 2, 0, 0, 2, 0, 0, 0]
pre_to_post(pre_list, children_list)
