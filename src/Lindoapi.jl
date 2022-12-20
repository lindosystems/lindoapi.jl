#=

 File: Lindoapi.jl
 Brief: The file that is executed when the package is loaded.
        Includes all files needed to run the Lindo API in Julia

 Authors: Pkg generate, James Haas, Mustafa Atlihan

 Bugs:

=#
module Lindoapi

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("Faild to build")
end
include(depsjl_path)

using CEnum
include("gen/liblindo_common.jl")
include("gen/liblindo_api.jl")
include("gen/liblindo_api_callback.jl")
include("gen/ctypes.jl")
include("MOI/MOI_wrapper.jl")

export Ctm, Ctime_t, Cclock_t

end # module
