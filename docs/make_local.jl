using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=(joinpath(@__DIR__, "../") |> normpath))

include("makedocs_include.jl")
