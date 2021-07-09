module LINDO

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("LINDO was not build properly. Please run Pkg.build(\"LINDO\").")
end
include(depsjl_path)
# Module initialization function

using CEnum
include("gen/liblindo_common.jl")
include("gen/liblindo_api.jl")
include("gen/ctypes.jl")
export Ctm, Ctime_t, Cclock_t

end # module
