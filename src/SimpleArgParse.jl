module SimpleArgParse

using OrderedCollections: OrderedDict
import Base.shell_split

# types
export ArgForms, ArgumentParser, ArgumentValues, InteractiveUsage,
    RealValidator, StrValidator

# functions
export shell_split, add_argument!, add_example!, args_pairs, colorprint, 
    help, parse_args!, validate

# @static if VERSION ≥ v"1.11"
#     # therein declare public identifiers
#     include("public.jl")
# end

include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

end # module SimpleArgParse
