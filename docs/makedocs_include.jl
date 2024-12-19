using YAArguParser
using Documenter, Dates

makedocs(
    modules = [YAArguParser, Base.get_extension(YAArguParser, :ParseDatesExt)],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Adam Erickson <adam.michael.erickson@gmail.com>, Eben60",
    sitename = "YAArguParser.jl",
    pages = Any[
        "Preface" => "index.md", 
        "Usage" => "usage.md", 
        "Changelog, Related packages, License" => "finally.md", 
        "Docstrings" => "docstrings.md"
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
    # strict = true,
    # clean = true,
)