using Keygen
using Test

@testset "Keygen.jl" begin

    @testset "documenter_keygen-added" begin
        using Example
        documenter_keygen(user="JuliaLang", repo="git@github.com:JuliaLang/Example.jl.git")
    end

    @testset "documenter_keygen-deved" begin
        using Pkg;
        Pkg.develop("Example")
        using Example
        documenter_keygen(Example)
    end

end
