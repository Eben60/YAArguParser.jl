#!/usr/bin/env julia

# Example for validating arguments

# somehow we have to ensure that SimpleArgParse2 is installed in the current environment, 
# otherwise try to switch the environment

using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse2")
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

using SimpleArgParse2
using SimpleArgParse2: AbstractArgumentParser

@kwdef mutable struct LegacyArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    authors::Vector{String} = String[]
    documentation::String = ""
    repository::String = ""
    license::String = ""
end

lp = initparser(LegacyArgumentParser; license="MIT", authors=["Eben60"], description="Example how to extend an argument parser")
@assert lp.ap.description == lp.description