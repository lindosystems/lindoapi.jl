"""
Largest Small Polygon
from the COPS3.0 test set

Problem Statement:
Maximize the total area of the n-polygon such that the diameter
of the polygon is less than or equal to 1 and that each vertex angle is
in an increasing order.

Max A(n) = 1/2 * ∑_{i ∈ 1:nᵥ-1} r_{i+1}r_{i}sin(θ_{i+1} - θ_{i})
Subject to
    r_{i}^2 + r_{j}^2 - 2r_{i}r_{j}cos(θ_{i} - θ_{j}) ≦ 1           1 ≦ i ≦ nᵥ
                                                                    i < j ≦ nᵥ
                        θ_{i} ≦ θ_{i+1}                             1 ≦ i ≦ nᵥ
                    θ_{i} ∈ [0, π], r_{i} ≧ 0                       1 ≦ i ≦ nᵥ


User inputs:
n_v: Number of vertices of polygon.


To run sample
    include("/PathToUse/JuMP_interface/ex_Largest_Small_Polygon.jl")

To update to the most current version of Lindoapi.jl
Run in REPL:
    using Pkg
    Pkg.add(url="https://github.com/lindosystems/lindoapi.jl")

This sample also uses the libraries Printf and Plots
both are not added as dependencies when installing Lindoapi.jl
If not installed yet
Run in REPL:
    using Pkg
    Pkg.add("Plots")
    Pkg.add("Printf")

"""

using Lindoapi
using JuMP
using Plots
using Printf

# number of vertices
# n_v = 8
# Get n_v from user input

use_global = false
n_v = 5


# initialize an empty model
model = Model( Lindoapi.Optimizer)
set_optimizer_attribute(model,"use_Global",use_global)
# make the two variable arrays of radius and theta
# with the constraints
@variable(model, r[1:n_v] >= 0)
@variable(model, 0 <= θ[1:n_v] <= pi)
# Fix the position of the last vertex
@NLconstraint(model, r[n_v] == 0)
@NLconstraint(model, θ[n_v] == pi)
# Maximize area of the n-polygon
@NLobjective(model,
             Max,
             0.5*sum(r[i+1]*r[i]*sin(θ[i+1] - θ[i]) for i in 1:(n_v-1))
             )
# Constrain the diameter to be less than or equal to one
@NLconstraint(model,
              [i = 1:(n_v - 1), j = (i+1):n_v],
              r[i]^2 + r[j]^2 - 2*r[i]*r[j]*cos(θ[i] - θ[j]) <= 1
              )
# Enforce ordering of vertex angles
@NLconstraint(model,
              [i = 1:(n_v - 1)],
              θ[i] - θ[i+1] <= 0
              )
# Model is configured now optimize
optimize!(model)

# Get area of n-polygon
objVal = objective_value(model, result=1)

# use a `.` to apply an operation
# getting variables from solved
r_star = value.(r)
θ_star = value.(θ)
# converting polar to rectangular coordinates
x = r_star.*cos.(θ_star)
y = r_star.*sin.(θ_star)

# printing results
println(termination_status(model))
@printf("Area of %d-polygon: %.5f\n", n_v, objVal)
println("Polar and Rectangular Coordinates")
println("==============================================")
println("   (r, θ) \t\t\t (x, y)")
for i in 1:n_v
    @printf("%d: (%.3f, %.3f) \t\t (%.3f, %.3f)\n",
     i, r_star[i], θ_star[i], x[i], y[i])
end
println("==============================================")

# ploting results
plot(
    Shape(x,y),
    title = "Largest Small $(n_v)-Polygon",
    xlim=(-1,1),
    ylim=(-0.1,1.1),
    xlabel = "x",
    ylabel = "y",
    legend = false)
scatter!(x,y)
