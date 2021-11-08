


using Lindoapi
using JuMP
using Printf


cost = [0 4 5 8 2
        4 0 3 4 6
        5 3 0 1 7
        8 4 1 0 4
        2 6 7 4 0
        ]

n_regions, m_cities = size(cost)

K = 2

mutable struct lockox_report
        obj_value
        x_star
        y_star
        reduce_cost_x
        reduce_cost_y
        dual_open_lim
        dual_region
        dual_assign
        slacks
        function lockox_report(model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes)
                lr               = new()
                lr.obj_value     = objective_value(model)
                lr.x_star        = value.(x)
                lr.y_star        = value.(y)
                lr.reduce_cost_x = reduced_cost.(x)
                lr.reduce_cost_y = reduced_cost.(y)
                lr.dual_open_lim = JuMP.dual.(K_open_boxes)
                lr.dual_region   = JuMP.dual.(One_per_region)
                lr.dual_assign   = JuMP.dual.(assign_to_open_boxes)
                lr.slacks        = JuMP.get_optimizer_attribute(model, Lindoapi.Slack_or_Surplus())
                return lr
        end
end

function LockBox(model, x, y)

        @NLobjective(model,
                     Min,
                     sum(x[i,j]*cost[i,j] for i in 1:n_regions, j in 1:m_cities)
                     )

        K_open_boxes         = @NLconstraint(model, sum(y[j] for j in 1:m_cities) == K)
        One_per_region       = @NLconstraint(model, [i = 1:n_regions],
                                             sum(x[i,j] for j in 1:m_cities) == 1
                                            )
        assign_to_open_boxes = @NLconstraint(model,  [i in 1:n_regions, j = 1:m_cities],
                                             x[i,j] <= y[j]
                                            )
        optimize!(model)
        return model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes
end

function integer_model()
        model = Model(Lindoapi.Optimizer)
        @variable(model, x[1:n_regions, 1:m_cities], Bin)
        @variable(model, y[1:m_cities], Bin)
        model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes = LockBox(model, x, y)
        return lockox_report(model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes)
end

function lp_relaxation_model()
        model = Model(Lindoapi.Optimizer)
        @variable(model, x[1:n_regions, 1:m_cities]>=0)
        @variable(model, y[1:m_cities]>=0)
        model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes = LockBox(model, x, y)
        return lockox_report(model, x, y, K_open_boxes, One_per_region, assign_to_open_boxes)
end


function main()
        @info("Solving MIP")
        lockbox_mip = integer_model()
        @info("Solving LP")
        lockbox_lp  = lp_relaxation_model()
        slack_pos = 1

        println("MIP Objective Value          : $(lockbox_mip.obj_value)")
        println("LP Relaxation Objective Value: $(lockbox_mip.obj_value)")

        println("Variable       MIP_Value & MIP_Reduced_Cost      Relaxed_Value & Relaxed_Reduced_Cost")
        println("=====================================================================================")
        for i in 1:n_regions, j in 1:m_cities
                @printf("x(%d, %d) %15d    %d %30.2f     %.2f\n",
                 i, j, lockbox_mip.x_star[i,j], lockbox_mip.reduce_cost_x[i,j],
                  lockbox_lp.x_star[i,j], lockbox_lp.reduce_cost_x[i,j])
        end
        for j in 1:m_cities
                @printf("   y(%d) %15d    %d %30.2f     %.2f\n",
                 j, lockbox_mip.y_star[j], lockbox_mip.reduce_cost_y[j],
                  lockbox_lp.y_star[j], lockbox_lp.reduce_cost_y[j])
        end
        println("=====================================================================================\n")
        println("Row               MIP_Slack & MIP_Dual_Price      Relaxed_Slack & Relaxed_Dual_Price")
        @printf(" open_lim   %15d    %d %30.2f     %.2f\n",
                 lockbox_mip.slacks[slack_pos], lockbox_mip.dual_open_lim,
                 lockbox_lp.slacks[slack_pos], lockbox_lp.dual_open_lim,)
        slack_pos += 1

        for i in 1:length(lockbox_mip.dual_region)
                @printf("region(%.2d)  %15d    %d %30.2f     %.2f\n", i,
                         lockbox_mip.slacks[slack_pos], lockbox_mip.dual_region[i],
                         lockbox_lp.slacks[slack_pos], lockbox_lp.dual_region[i],)
                         slack_pos+=1
        end
        for i in 1:length(lockbox_mip.dual_assign)
                @printf("assign(%.2d)  %15d    %d %30.2f     %.2f\n", i,
                         lockbox_mip.slacks[slack_pos], lockbox_mip.dual_assign[i],
                         lockbox_lp.slacks[slack_pos], lockbox_lp.dual_assign[i],)
                         slack_pos+=1
        end
end

main()
