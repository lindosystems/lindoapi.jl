




using Lindoapi
using JuMP
using Printf

# initilze model
model = Model(Lindoapi.Optimizer)

n = 10
m = 10

source = [8 8 2 26 12 1 6 18 18 1.0]
destination = [19 2 33 5 11 11 2 14 2 1.0]
cost = [
        15  3 23  1 19 14  6 16 41 33
        13 17 30 36 20 17 26 19  3 33
        37 17 30  5 48 27  8 25 36 21
        13 13 31  7 35 11 29 41 34  3
        31 24  8 30 28 33  2  8  1  8
        32 36 12  9 18  1 44 49 11 11
        49  6 17  0 42 45 22  9 10 47
         2 21 18 40 47 27 27 49 19 42
        13 16 25 21 19  0 32 20 32 35
        23 42  2  0  9 30  5 29 31 29.0
]


@variable(model, x[1:n,1:m])
for i in 1:n, j in 1:m
        @NLconstraint(model, x[i,j] >= 0)
end

for i in 1:m
        @NLconstraint(model, sum(x[i,j] for j in 1:n) >= source[i])
end

for j in 1:n
        @NLconstraint(model, sum(x[i,j] for i in 1:m) >= destination[j])
end

@NLobjective(model, Min, sum(cost[i,j]*x[i,j]^2 for i in 1:n, j in 1:m))


# Call the optimizer
optimize!(model)

# Quary objective value
objVal = objective_value(model)
