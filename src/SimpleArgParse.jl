module SimpleArgParse

export ArgumentParser, add_argument!, add_example!, generate_usage, help, parse_args!, 
    get_value, set_value!, colorize, 
    colorprint, args_pairs, PromptedParser

using OrderedCollections: OrderedDict

include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

include("promptedparser.jl")

end # module SimpleArgParse
