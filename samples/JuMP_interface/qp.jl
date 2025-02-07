"""


A Julia programming example of interfacing with LINDO API Using JuMP.
See path_to_samples/soft_wrapper/qp.jl for the same model using
the soft wrapper.

                    Portfolio Selection Problem
                       The Markowitz Model.

       MAXIMIZE  r(1)w(1) + ... +r(n)w(n)
           st.       sum_{ij} Q(i,j)w(i)w(j) <= K
                         w(1) + ..... + w(n)  = 1
                         w(1),         ,w(n) >= 0
           where
           r(i)  : return on asset i
           Q(i,j): covariance between the returns of i^th and
                   j^th assets.
           K     : a scalar denoting the level of risk of loss.
           w(i)  : proportion of total budget invested on asset i

           Covariance Matrix:
                  w1    w2    w3    w4
             w1 [ 1.00  0.64  0.27  0.    ]
             w2 [ 0.64  1.00  0.13  0.    ]
             w3 [ 0.27  0.13  1.00  0.    ]
             w4 [ 0.    0.    0.    1.00  ]

           Returns Vector:
                    w1    w2    w3    w4
           r =   [ 0.30  0.20 -0.40  0.20  ]

           Risk of Loss Factor:
           K = 0.4

To run sample
   include("/PathToUse/JuMP_interface/qp.jl")

To update to the most current version of LindoAPI.jl
     Run in REPL:
         using Pkg
         Pkg.add(url="https://github.com/lindosystems/LindoAPI.jl"n)
"""

using LindoAPI
using JuMP
using Printf

num_assets = 4

Q = [ 1.00 0.64 0.27 0.
      0.64 1.00 0.13 0.
      0.27 0.13 1.00 0.
      0.   0.   0.   1.00
    ]

r = [0.300,0.200,-0.400,0.200]

K = 0.5



model = Model(LindoAPI.Optimizer)



@variable(model, w[1:num_assets] >= 0)

@objective(model, Max, sum(w[i]*r[i] for i in 1:num_assets))

portfolio_con = @constraint(model, sum(w[i] for i in 1:num_assets) == 1)
risk_con      = @constraint(model, w' * Q * w <= K)

optimize!(model)



obj_val     = objective_value(model)
w_star      = value.(all_variables(model))
reducedCost = reduced_cost.(all_variables(model))
variance    = w_star'Q*w_star

portfolio_con_dual = dual(portfolio_con)
risk_con_dual      = dual(risk_con)
portfolio_con_slack, risk_con_slack = get_optimizer_attribute(model,
                                        LindoAPI.Slack_or_Surplus())

@printf("Expected Return: %.5f \n", obj_val)
@printf("Variance       : %.5f \n", variance)
println()
println("Variable      Value        Reduced Cost")
println("========================================")
for i in 1:num_assets
@printf("w[%d] %15.3f %15.3f \n", i, w_star[i], reducedCost[i])
end

println()
println("    Row           Slack or Surplus   Dual Price")
println("===============================================")
@printf("portfolio_con %15.3f %15.3f \n",
        portfolio_con_slack, portfolio_con_dual)
@printf("risk_con      %15.3f %15.3f \n",
        risk_con_slack, risk_con_dual)

 