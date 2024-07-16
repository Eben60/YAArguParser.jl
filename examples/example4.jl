#!/usr/bin/env julia

# Example for extending ArgumentParser struct

################

# We check if YAArguParser is installed in the current environment, 
# otherwise we try to switch the environment, or install it into a 
# temporary environment.

try
    using YAArguParser
catch
    using Pkg
    parentdir = (dirname(@__DIR__)) 
    parentdir_name = parentdir |> basename
    if parentdir_name == "YAArguParser.jl"
        println("activating parent dir")
        Pkg.activate(parentdir)
    else
        Pkg.activate(; temp=true)
        Pkg.add("YAArguParser")
    end
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