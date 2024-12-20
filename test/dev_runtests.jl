using Pkg, TOML

prev_proj = Base.active_project()
Pkg.activate(@__DIR__)
path = joinpath(@__DIR__ , "..") |> normpath

project_toml_path = joinpath(path, "Project.toml")
project_toml = TOML.parsefile(project_toml_path)
parent_proj_name = project_toml["name"]

using Suppressor
@suppress begin
Pkg.develop(;path)
end



complete_tests = false
include("runtests.jl")

@suppress begin
Pkg.rm(parent_proj_name)
Pkg.activate(prev_proj)
end

# if it errors, it will leave entry for 
# YAArguParser = "bcbd4c87-030e-4da8-a7f0-f342a29caad3"
# in the Project.toml.
# it doesn't actually belong there
# don't check in this change!