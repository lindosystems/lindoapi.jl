using JuMP, PiecewiseLinearOpt, Lindoapi,  BenchmarkTools

function test_model()
      optimizer = Lindoapi
      model = Model(optimizer.Optimizer)
      JuMP.set_optimizer_attribute(model, "silent", true)
      @variable(model, x>=0)
      @variable(model, y>=0)
      z = piecewiselinear(model, x,y, 0:0.01:1, 0:0.01:1, (u,v) -> exp(u+v))
      @NLobjective(model, Min, z*1)
      optimize!(model)
end

# var  = ["x1" "x2" "x3" "x4"]
# coef = [1 1 8 1]
# n = length(var)
#
#
# for i in 1:n
#     if coef[i] != 1
#         print(var[i], " ", coef[i], " ", "*", " ")
#     else
#         print(var[i], " ")
#     end
#     if i != 1
#         print("+", " ")
#     end
# end
# print("h", " ", "-")
