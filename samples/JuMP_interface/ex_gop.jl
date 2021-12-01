"""
Colville Function

Minimize f(x) = 100(x²₁ - x₂)² + (x₁ - 1)² + (x₃ - 1)² + 90(x²₃ - x₄)²
       + 10.1((x₂ - 1)² + (x₄ - 1)²) + 19.8(x₂ - 1)(x₄ - 1)
Such that: -10 ≦ xᵢ ≦ 10

f(x^*) = 0, at x^* = (1, 1, 1, 1)

Purpose:
 This sample demonstrates the Lindo API's Global solver
 as well as how that global solver using `set_optimizer_attribute`.

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


use_global = true

model = Model(Lindoapi.Optimizer)

function logFunc(pModel, line, uDict)
   param_ptr = Cdouble[-1.0]
   Lindoapi.LSgetModelDouParameter(pModel, Lindoapi.LS_DPARAM_CALLBACKFREQ, param_ptr)
   println(param_ptr[1])
    @printf("%s %s",uDict["Prefix"], line)
    return Int32(0)
end

function cbFunc(pModel, loc, uDict)
   dObj = Cdouble[-1]
   Lindoapi.LSgetCallbackInfo( pModel, loc, Lindoapi.LS_DINFO_POBJ, dObj)
   println(dObj)
   return Int32(0)
end

uDict = Dict(
"Prefix"  => "LP sample:",
"Postfix" => "...",
"model"     => 11
)


MOI.set(model, Lindoapi.LogFunction(uDict), logFunc)
MOI.set(model, Lindoapi.CallbackFunction(uDict), cbFunc)

set_optimizer_attribute(
         model,
         Lindoapi.LindoDouParam(Lindoapi.LS_DPARAM_CALLBACKFREQ),
         2000.00
      )

println(      get_optimizer_attribute(
               model,
               Lindoapi.LindoDouParam(Lindoapi.LS_DPARAM_CALLBACKFREQ),
            ))

set_optimizer_attribute(model, "use_Global", use_global)

@variable(model, -10 <= x[1:4] <= 10)

@NLobjective(model,
             Min,
             100*(x[1]^2 - x[2])^2 + (x[1] - 1)^2 + (x[3] - 1)^2
             + 90*(x[3] - x[4])^2  + 10.1*((x[2] - 1)^2 +(x[4] -1)^2)
             + 19.8*(x[2] - 1)*(x[4] - 1)
             )

optimize!(model)

x_star = value.(x)
for i in 1:4
   println("x_$(i) = ", x_star[i])
end
