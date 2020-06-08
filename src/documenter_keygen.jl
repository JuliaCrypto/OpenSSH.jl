export documenter_keygen

using Base64
import LibGit2: GITHUB_REGEX


"""
    documenter_keygen()

Generates the SSH keys that are required for the automatic deployment of documentation with Documenter from a builder to GitHub Pages.

By default the links in the instructions need to be modified to correspond to actual URLs.

    documenter_keygen(; user="USER", repo="REPO")

The optional `user` and `repo` keyword arguments can be specified so that the URLs in the printed instructions could be copied directly. They should be the name of the GitHub user or organization where the repository is hosted and the full name of the repository,
respectively.

# Examples
```julia-repl
julia> using OpenSSH
julia> documenter_keygen()
[ Info: add the public key below to https://github.com/USER/REPO/settings/keys with read/write access:
ssh-rsa AAAAB3NzaC2yc2EAAAaDAQABAAABAQDrNsUZYBWJtXYUk21wxZbX3KxcH8EqzR3ZdTna0Wgk...jNmUiGEMKrr0aqQMZEL2BG7 username@hostname
[ Info: add a secure environment variable named 'DOCUMENTER_KEY' to https://travis-ci.com/USER/REPO/settings (if you deploy using Travis CI) or https://github.com/USER/REPO/settings/secrets (if you deploy using GitHub Actions) with value:
LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBNnpiRkdXQVZpYlIy...QkVBRWFjY3BxaW9uNjFLaVdOcDU5T2YrUkdmCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
julia> documenter_keygen(user="JuliaDocs", repo="OpenSSH.jl")
[Info: add the public key below to https://github.com/JuliaDocs/OpenSSH.jl/settings/keys with read/write access:
ssh-rsa AAAAB3NzaC2yc2EAAAaDAQABAAABAQDrNsUZYBWJtXYUk21wxZbX3KxcH8EqzR3ZdTna0Wgk...jNmUiGEMKrr0aqQMZEL2BG7 username@hostname
[ Info: add a secure environment variable named 'DOCUMENTER_KEY' to https://travis-ci.com/JuliaDocs/OpenSSH.jl/settings (if you deploy using Travis CI) or https://github.com/JuliaDocs/OpenSSH.jl/settings/secrets (if you deploy using GitHub Actions) with value:
LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBNnpiRkdXQVZpYlIy...QkVBRWFjY3BxaW9uNjFLaVdOcDU5T2YrUkdmCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
```
"""
function documenter_keygen(; user="USER", repo="REPO")
    # Error checking. Do the required programs exist?
    if Sys.iswindows()
        success(`where where`)      || error("'where' not found.")
        success(`where ssh-keygen`) || error("'ssh-keygen' not found.")
    else
        success(`which which`)      || error("'which' not found.")
        success(`which ssh-keygen`) || error("'ssh-keygen' not found.")
    end


    directory = pwd()
    filename  = "documenter-private-key"

    isfile(filename) && error("temporary file '$(filename)' already exists in working directory")
    isfile("$(filename).pub") && error("temporary file '$(filename).pub' already exists in working directory")

    # Generate the ssh key pair.
    success(`ssh-keygen -N "" -f $filename`) || error("failed to generate a SSH key pair.")

    # Prompt user to add public key to github then remove the public key.
    let url = "https://github.com/$user/$repo/settings/keys"
        @info("add the public key below to $url with read/write access:")
        println("\n", read("$filename.pub", String))
        rm("$filename.pub")
    end

    # Base64 encode the private key and prompt user to add it to travis. The key is
    # *not* encoded for the sake of security, but instead to make it easier to
    # copy/paste it over to travis without having to worry about whitespace.
    let travis_url = "https://travis-ci.com/$user/$repo/settings",
        github_url = "https://github.com/$user/$repo/settings/secrets"
        @info("add a secure environment variable named 'DOCUMENTER_KEY' to " *
              "$(travis_url) (if you deploy using Travis CI) or " *
              "$(github_url) (if you deploy using GitHub Actions) with value:")
        println("\n", base64encode(read(filename, String)), "\n")
        rm(filename)
    end
end

"""
    documenter_keygen(package::Module; remote="origin")

This method attempts to guess the package URLs from the Git remote.

`package` needs to be the top level module of the package. The `remote` keyword argument can be used to specify which Git remote is used for guessing the repository's GitHub URL.

This method requires `git` to be available from the command line.

!!! note
    the package must be in development mode. Make sure you run `pkg> develop pkg` from the Pkg REPL, or `Pkg.develop(\"pkg\")` before generating the SSH keys.

# Examples
```julia-repl
julia> using OpenSSH
julia> documenter_keygen(Keygen)
[Info: add the public key below to https://github.com/JuliaDocs/OpenSSH.jl/settings/keys with read/write access:
ssh-rsa AAAAB3NzaC2yc2EAAAaDAQABAAABAQDrNsUZYBWJtXYUk21wxZbX3KxcH8EqzR3ZdTna0Wgk...jNmUiGEMKrr0aqQMZEL2BG7 username@hostname
[ Info: add a secure environment variable named 'DOCUMENTER_KEY' to https://travis-ci.com/JuliaDocs/OpenSSH.jl/settings (if you deploy using Travis CI) or https://github.com/JuliaDocs/OpenSSH.jl/settings/secrets (if you deploy using GitHub Actions) with value:
LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBNnpiRkdXQVZpYlIy...QkVBRWFjY3BxaW9uNjFLaVdOcDU5T2YrUkdmCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
```
"""
function documenter_keygen(package::Module; remote="origin")
    # Error checking. Do the required programs exist?
    if Sys.iswindows()
        success(`where where`)      || error("'where' not found.")
        success(`where ssh-keygen`) || error("'ssh-keygen' not found.")
        success(`where git`)        || error("'git' not found.")
    else
        success(`which which`)      || error("'which' not found.")
        success(`which ssh-keygen`) || error("'ssh-keygen' not found.")
        success(`which git`)        || error("'git' not found.")
    end

    path = package_devpath(package)

    # Are we in a git repo?
    user, repo = cd(path) do
        success(`git status`) || error("Failed to run `git status` in $(path). 'Keygen.documenter_keygen' only works with Git repositories.")

        let r = readchomp(`git config --get remote.$remote.url`)
            m = match(GITHUB_REGEX, r)
            m === nothing && error("no remote repo named '$remote' found.")
            m[2], m[3]
        end
    end

    # Generate the ssh key pair.
    documenter_keygen(; user=user, repo=repo)
end
