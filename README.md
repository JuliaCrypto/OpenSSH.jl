# OpenSSH

[![Build Status](https://github.com/JuliaCrypto/OpenSSH.jl/workflows/CI/badge.svg)](https://github.com/JuliaCrypto/OpenSSH.jl/actions)

Generate keys!

## documenter_keygen
```julia
documenter_keygen()
```

Generates the SSH keys that are required for the automatic deployment of documentation with Documenter from a builder to GitHub Pages.

By default the links in the instructions need to be modified to correspond to actual URLs.

```julia
julia> using OpenSSH
julia> documenter_keygen()
```
------

```julia
documenter_keygen(; user="USER", repo="REPO")
```

The optional `user` and `repo` keyword arguments can be specified so that the URLs in the printed instructions could be copied directly. They should be the name of the GitHub user or organization where the repository is hosted and the full name of the repository,
respectively.

```julia
julia> using OpenSSH
julia> documenter_keygen(user="JuliaDocs", repo="OpenSSH.jl")
```

-------

```julia
documenter_keygen(package::Module; remote="origin")
```

This method attempts to guess the package URLs from the Git remote.

`package` needs to be the top level module of the package. The `remote` keyword argument can be used to specify which Git remote is used for guessing the repository's GitHub URL.

This method requires `git` to be available from the command line.

Note: the package must be in development mode. Make sure you run `pkg> develop pkg` from the Pkg REPL, or `Pkg.develop(\"pkg\")` before generating the SSH keys.


```julia
julia> using OpenSSH, MatLang
julia> documenter_keygen(MatLang)
```

# Motivation
The first goal is to provide those OpenSSH APIs (like ssh-keygen). In addition, it plans to have an application layer, that is to provide a single goto package that can be used for generating keys for all sorts of applications (e.g Documenter, GitHub secrets, etc). PkgTemplates will also use this single Keygen package for generating the keys it needs for its plugins.
