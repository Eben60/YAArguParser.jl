#!/usr/bin/env julia

# Example for extending ArgumentParser struct

################

# We check if YAArguParser is installed in the current environment, 
# otherwise we try to switch the environment.

using Pkg, UUIDs

pkg_name = "YAArguParser"
pkg_uuid = UUID("e3fa765b-3027-4ef3-bb12-e639c1e60c6e")

pkg_available = ! isnothing(Pkg.Types.Context().env.pkg) && Pkg.Types.Context().env.pkg.name == pkg_name
pkg_available = pkg_available || haskey(Pkg.dependencies(), pkg_uuid)

if ! pkg_available
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

################

using YAArguParser
using YAArguParser: AbstractArgumentParser

@kwdef mutable struct LegacyArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    authors::Vector{String} = String[]
    documentation::String = ""
    repository::String = ""
    license::String = ""
end

lp = initparser(LegacyArgumentParser; license="MIT", authors=["Eben60"], description="Example how to extend an argument parser")
@assert lp.ap.description == lp.description