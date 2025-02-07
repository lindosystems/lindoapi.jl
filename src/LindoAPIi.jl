#=

 File: LindoAPI.jl
 Brief: The file that is executed when the package is loaded.
        Includes all files needed to run the Lindo API in Julia

 Authors: Pkg generate, James Haas, Mustafa Atlihan

 Bugs:

=#
module LindoAPI

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("Faild to build")
end
include(depsjl_path)

# If there is no Lindo API, warn the user
# Instruct them to install the Lindo API
# and then reinstall this package
if !isfile(liblindo)
    @warn "Lindo API not found. Please install the Lindo API and reinstall this package."
else
    using CEnum
    include("gen/liblindo_common.jl")
    include("gen/liblindo_api.jl")
    include("gen/liblindo_api_callback.jl")
    include("gen/ctypes.jl")
    include("MOI/MOI_wrapper.jl")
    export Ctm, Ctime_t, Cclock_t
end



end # module
