# using Pkg
# Pkg.activate(@__DIR__)
# Pkg.develop(path=(joinpath(@__DIR__, "../") |> normpath))

using Documenter, YAArgParser

makedocs(
    modules = [YAArgParser],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Adam Erickson <adam.michael.erickson@gmail.com>, Eben60",
    sitename = "YAArgParser.jl",
    pages = Any[
        "Preface" => "index.md", 
        "Usage" => "usage.md", 
        "Changelog, Related packages, License" => "finally.md", 
        "Docstrings" => "docstrings.md"
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
)
;

# deployment done on the server anyway
# don't normally run deploydocs here
deploydocs(
    repo = "github.com/Eben60/YAArgParser.jl.git",
    versions = nothing,
    push_preview = true
)
