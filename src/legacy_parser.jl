using YAArguParser

@kwdef mutable struct LegacyArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    authors::Vector{String} = String[]
    documentation::String = ""
    repository::String = ""
    license::String = ""
end
