"""
Lockbox

Problem Statement:
Minimize the cost of waiting for a payment to clear and the amount
  spent on operating lockboxes.

Purpose:
 This sample demonstrates:
  * Multi-dimensional array of variables.
  * Arrays of constraints
  * Printing solution


 To run sample
     include("/PathToUse/ex_gop.jl")

To update to the most current version of Ipopt.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")

"""



using Lindoapi
using JuMP
using Printf

region = ["West", "Midwest", "East", "South"]
cities = ["L.A.", "Cincinnati", "Boston", "Houston"]

avg_daily_value = [30, 12, 36, 18] * 10000
clearing_time = [ 2 4 6 6
                  4 2 5 5
                  6 5 2 5
                  7 5 6 3
                ]
intrest_rate = 0.10
lockbox_cost = 90000

loss_interest = avg_daily_value*intrest_rate .* clearing_time

n_regions, m_cities = size(loss_interest)

K = 4


model = Model(Lindoapi.Optimizer)

@variable(model, x[1:n_regions, 1:m_cities], Bin)
@variable(model, y[1:m_cities], Bin)

@NLobjective(model, Min,
             sum(x[i,j]*loss_interest[i,j] for i in 1:n_regions, j in 1:m_cities)
            + lockbox_cost*sum(y[j] for j in 1:m_cities)
             )
             
One_per_region       = @NLconstraint(model, [i = 1:n_regions],
                                     sum(x[i,j] for j in 1:m_cities) == 1
                                    )
assign_to_open_boxes = @NLconstraint(model, [j = 1:m_cities],
                             sum(x[i,j] for i in 1:n_regions) <= y[j]*m_cities
                        )
optimize!(model)

obj_val = objective_value(model)
x_star  = value.(x)

@printf("Total yearly cost: %.2f\n", obj_val)
@printf("%-10s %s\n", "Region", "Lockbox Location")
println("============================")
for i in 1:n_regions, j in 1:m_cities
  if x_star[i,j] != 0
    @printf("%-15s %s\n", region[i], cities[j])
  end
end
