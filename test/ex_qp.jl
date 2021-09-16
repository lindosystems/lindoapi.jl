# This exsample demonstraits how the LINDO API can utilize the JuMP interface
#
#
#
# The JuMP functions/ Macros used
#
# Model(Lindoapi.Optimizer)
# @variable
# @NLexpression
# @NLconstraint
# @NLobjective
# optimize!(model)
# objective_value(model)
# value(w[i])

# Set up and solve a (quadratic) portfolio model with LINDO API.
#
#                    Portfolio Selection Problem
#                       The Markowitz Model.
#
#       MAXIMIZE  r(1)w(1) + ... +r(n)w(n)
#           st.       sum_{ij} Q(i,j)w(i)w(j) <= K
#                         w(1) + ..... + w(n)  = 1
#                         w(1),         ,w(n) >= 0
#           where
#           r(i)  : return on asset i
#           Q(i,j): covariance between the returns of i^th and
#                   j^th assets.
#           K     : a scalar denoting the level of risk of loss.
#           w(i)  : proportion of total budget invested on asset i

#           Covariance Matrix:
#                  w1    w2    w3    w4
#             w1 [ 1.00  0.64  0.27  0.    ]
#             w2 [ 0.64  1.00  0.13  0.    ]
#             w3 [ 0.27  0.13  1.00  0.    ]
#             w4 [ 0.    0.    0.    1.00  ]

#           Returns Vector:
#                    w1    w2    w3    w4
#           r =   [ 0.30  0.20 -0.40  0.20  ]

#           Risk of Loss Factor:
#           K = 0.4

using Lindoapi
using JuMP
using Printf


n = 4
Σ = [
    1.00 0.64 0.27 0.00;
    0.64 1.00 0.13 0.00;
    0.27 0.13 1.00 0.00;
    0.00 0.00 0.00 1.00
    ]
r = [0.30  0.20 -0.40  0.20]
K = 0.4

# initilze model
model = Model(Lindoapi.Optimizer)

# Declaring n model variables of portfolio weights
@variable(model, w[1:n])

# Each weight must be positive
@NLconstraint(model, sum(w[i] for i in 1:n) == 1)
for i in 1:n
    @NLconstraint(model, w[i] >= 0)
end

#=
    variance
 Param model: A model object created by JuMP
 Param w: a vector of model variables
 Param Σ: Covarience matrix
 Returns: variance an expresion for x'Σx that can be used thghrout the model
=#
variance = @NLexpression(model, sum(w[i] * sum(Σ[i,j] * w[j] for j in 1:n) for i in 1:n))
# Portfolio variance is less then or equal to the risk of loss factor
@NLconstraint(model, variance  <= K)
# Maximize the expected return of the portfolio
@NLobjective(model, Max, sum(w[i]*r[i] for i in 1:n))
# Call the optimizer
optimize!(model)
# Quary objective value
objVal = objective_value(model)
#=
    Printing out objective value and primal solution
=#
println()
@printf "Objective is: %.7f \n" objVal
@printf "%s  %20s\n" "Index" "Primal Value"
println(repeat('=', 30))
for i in 1:n
    @printf "%i %20.6f \n" i value(w[i])
end
println()
