"""
Beale Function

"""


using Lindoapi
using JuMP



model = Model(Lindoapi.Optimizer)
set_optimizer_attribute(model,"use_Global",true)

@variable(model, x)
@variable(model, y)

@NLobjective(model,
             Min,
             - (1 + cos(12*sqrt(x^2+y^2)))/(0.5*(x^2 + y^2) + 2)
             )

optimize!(model)
