"""
    package_devpath(pkg::Module)
Returns the path to the top level directory of a devved out package source tree. The package
is identified by its top level module `pkg`.
"""
function package_devpath(pkg::Module)
    pkg == parentmodule(pkg) || throw(ArgumentError("$(pkg) is a submodule. Use the package top-level module."))
    path = pathof(pkg)
    path === nothing && throw(ArgumentError("could not find path to $(pkg)."))
    name = String(nameof(pkg))

    # check that pkg is not originating from a standard installation directory
    # since those are supposed to be immutable.
    for depot in DEPOT_PATH
        sep = Sys.iswindows() ? "\\\\" : "/"
        if startswith(path, joinpath(depot, "packages", name)) &&
            occursin(Regex(name * sep * "\\w{4,5}" * sep * "src" * sep * name * ".jl"), path)
            throw(ArgumentError(string(
                "module $(name) was found in a standard installation directory. ",
                "Please make sure that $(name) is ready for development by running ",
                "`pkg> develop $(name)` from the Pkg REPL, or ",
                "`Pkg.develop(\"$(name)\")` from the Julia REPL, and try again.")))
        end
    end
    # We assume that the path to source file of pkg is ../Package/src/Package.jl, but we
    # return simply the top level directory of the package (i.e. ../Package)
    return normpath(joinpath(path, "..", ".."))
end
