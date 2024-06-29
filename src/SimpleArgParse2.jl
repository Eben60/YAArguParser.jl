module SimpleArgParse2

using Compat
using OrderedCollections: OrderedDict
import Base.shell_split

# types
export ArgForms, ArgumentValues, RealValidator, StrValidator, ArgumentParser, InteractiveArgumentParser

# functions
export shell_split, add_argument!, add_example!, args_pairs, colorprint, 
    help, parse_args!, validate, initparser

# in effect in Julia ≥ v1.11
@compat public AbstractValidator, AbstractArgumentParser # types
@compat public generate_usage!, get_value, getcolor, parse_arg, set_value! # functions

include("validator.jl")
include("datastructures.jl")
# include("legacy_parser.jl")
include("functions.jl")
include("utilities.jl")

include("precompile.jl")

end # module SimpleArgParse2
