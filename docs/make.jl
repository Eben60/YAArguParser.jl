# push!(LOAD_PATH,"../src/")
using Pkg

splitpath(Base.active_project())[end-1] == "docs" || Pkg.activate("docs")

using Documenter, SimpleArgParse

# generate documentation locally. 
# keep in mind .gitignore - deps/deps.jl
makedocs(
    modules = [SimpleArgParse],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Adam Erickson <adam.michael.erickson@gmail.com>, Eben60",
    sitename = "SimpleArgParse.jl",
    pages = Any["Home" => "index.md", ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
    # strict = true,
    # clean = true,
)
;

# depoloyment done on the server anyway
# don't normally run deploydocs here
# deploydocs(
#     repo = "github.com/Eben60/SimpleArgParse.jl.git",
#     versions = nothing,
#     push_preview = true
# )