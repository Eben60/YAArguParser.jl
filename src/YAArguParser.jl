
"""
    Package YAArguParser v$(pkgversion(YAArguParser))

A parser of command line arguments.

Docs under https://eben60.github.io/YAArguParser.jl/
$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(YAArguParser)) : "")
"""
module YAArguParser

using Compat
using OrderedCollections: OrderedDict
import Base.shell_split

# types
export ArgumentParser, InteractiveArgumentParser, ArgForms, ArgumentValues, RealValidator, StrValidator

# functions
export add_argument!, add_example!, args_pairs, colorprint, 
    help, parse_args!, initparser

# in effect in Julia ≥ v1.11
@compat public AbstractValidator, AbstractArgumentParser # types
@compat public generate_usage!, get_value, getcolor, parse_arg, set_value!, 
    shell_split, validate, warn_and_return # functions

# breaking changes:
# parse_arg change arguments
# ArgumentValues add field


include("validator.jl")
include("datastructures.jl")
# include("legacy_parser.jl")
include("functions.jl")
include("utilities.jl")

include("precompile.jl")

end # module YAArguParser
