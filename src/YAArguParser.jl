
"""
    Package YAArguParser v$(pkgversion(YAArguParser))

A parser of command line arguments.

Docs under https://eben60.github.io/YAArguParser.jl/
$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(YAArguParser)) : "")
"""
module YAArguParser

using OrderedCollections: OrderedDict
import Base.shell_split

# types
export ArgumentParser, InteractiveArgumentParser, ArgForms, ArgumentValues, RealValidator, StrValidator

# functions
export add_argument!, add_example!, args_pairs, colorprint, 
    help, parse_args!, initparser

# public declarations - in effect in Julia ≥ v1.11
include("public.julia")

# # # function definitions for package extensions

function parse_datetime end
function specify_datetime_fmts end

# # # # # 

include("validator.jl")
include("datastructures.jl")
# include("legacy_parser.jl")
include("functions.jl")
include("utilities.jl")

include("precompile.jl")

end # module YAArguParser
