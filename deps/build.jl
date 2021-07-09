using Libdl

try ENV["LINDOAPI_HOME"]
catch
        error("Environment variable LINDOAPI_HOME is empty!")
        exit(0)
end

const PATH = ENV["LINDOAPI_HOME"]

const _DEPS_FILE = joinpath(dirname(@__FILE__), "deps.jl")
if isfile(_DEPS_FILE)
    rm(_DEPS_FILE)
end

function write_depsfile(path)
    open(_DEPS_FILE, "w") do f
        println(f, "const liblindo = \"$(escape_string(path))\"")
    end
end

is_64bits = Sys.WORD_SIZE == 64

function get_error_message_if_not_found()
    return """
    Unable to install LINDO.jl

    """

end

function write_depsfile(path)
    open(_DEPS_FILE, "w") do f
        println(f, "const liblindo = \"$(escape_string(path))\"")
    end
end

function ls_get_version(filename)
    open(filename, "r")
    lines = readlines(filename)
    LS_MAJOR = rsplit(lines[1],"=")[2]
    LS_MINOR= rsplit(lines[2],"=")[2]
    return LS_MAJOR, LS_MINOR
end

function library()
    liblindo = ""
    if Sys.iswindows()
        LS_MAJOR, LS_MINOR = ls_get_version(joinpath(PATH, "include/lsversion.sh"))
        if is_64bits
            liblindo = joinpath(PATH,"bin/win64/lindo64_"*LS_MAJOR*"_"*LS_MINOR)
        else
            liblindo = joinpath(PATH,"bin/win32/lindo32_"*LS_MAJOR*"_"*LS_MINOR)
        end
    elseif Sys.islinux()
        if is_64bits
            liblindo = joinpath(PATH,"bin/linux64/liblindo64")
        else
            liblindo = joinpath(PATH,"bin/linux32/liblindo32")
        end
    elseif Sys.isapple()
        if is_64bits
            liblindo = joinpath(PATH,"bin/osx64x86/liblindo64")
        else
            liblindo = joinpath(PATH,"bin/osx32x86/liblindo32")
        end
    else
        error("NOPE")#get_error_message_if_not_found()
    end
    return liblindo
end

function check_library(liblindo)
    if Libdl.dlopen_e(liblindo) == C_NULL
        return false
    else
        return true
    end
end

function try_installation()
    liblindo = library()
    if check_library(liblindo)
        write_depsfile(liblindo)
        @info "Found API location `$(liblindo)`"
        return
    else
        error(get_error_message_if_not_found())
    end
end




try_installation()
