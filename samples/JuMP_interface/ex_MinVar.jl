"""
Minimum Variance Portfolio

Problem Statement:
Minimize the variance of a portfolio of n assets. Such that the portfolio weights
sum to one, and there is no short selling (w_{i} ≧ 0). All for a desired minimum
expected return of R.


Minimize   :      V(w) = w'Σw
Subject to : ∑_{i ∈ 1:n} w_{i} = 1
                   w'r ≥ R
                   w_{i} ≥ 0

User inputs:
n: number of assets
Σ: covariance matrix
r: expected return of assets
R: desired minimum expected return of portfolio.


To run sample
    include("/PathToUse/ex_MinVar.jl")

To update to the most current version of Lindoapi.jl
Run in REPL:
    using Pkg
    Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")

This sample also uses the libraries Printf
and is not added as dependencies when installing Lindoapi.jl
If not installed yet
Run in REPL:
    using Pkg
    Pkg.add("Printf")

"""



using Lindoapi
using JuMP
using Printf

# User inputs
n = 4
Σ = [
    1.00 0.64 0.27 0.00;
    0.64 1.00 0.13 0.00;
    0.27 0.13 1.00 0.00;
    0.00 0.00 0.00 1.00
    ]
r = [0.30,  0.20, -0.40,  0.20]
R = 0.07

# initialize model
model = Model(Lindoapi.Optimizer)
# Declaring n model variables of portfolio weights
@variable(model,  w[1:n] >= 0)
# Portfolio weights sum to 1
portfolio_con = @NLconstraint(model, sum(w[i] for i in 1:n) == 1)
# Portfolio must be at least desired minimum expected return
return_con = @NLconstraint(model, sum(w[i]*r[i] for i in 1:n) >= R)
# Minimize portfolio variance
@NLobjective(model, Min, sum(w[i] * sum(Σ[i,j] * w[j] for j in 1:n) for i in 1:n))
# Call the optimizer
optimize!(model)
# Query objective value
objVal = objective_value(model)
w_star = value.(w)
rd     = reduced_cost.(w)
slacks = JuMP.get_optimizer_attribute(model, Lindoapi.Slack_or_Surplus())
μ_star = w_star'r
#Printing out objective value and primal solution
println()
@printf("Expected return :  %.4f \n", μ_star)
@printf("Variance        :  %.4f \n", objVal)
println("Index       Asset weight        Reduced Cost")
println(repeat('=', 45))
for i in 1:n
    @printf("w%i %20.6f %20.6f\n", i, w_star[i], rd[i])
end
println(repeat('=', 45))
println()
println("constraint       slack           Dual")
println("========================================")
@printf("Portfolio   %10.6f     %10.6f\n", slacks[1], JuMP.dual(portfolio_con))
@printf("Return      %10.6f     %10.6f\n", slacks[2], JuMP.dual(return_con))
println("========================================")
