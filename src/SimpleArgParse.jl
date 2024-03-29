module SimpleArgParse

export ArgumentParser, add_argument!, add_example!, generate_usage, help, parse_args!, 
    get_value, set_value!, colorize, 
    colorprint, args_pairs, PromptedParser

using OrderedCollections: OrderedDict

###
### Data Structures
###

"Command-line arguments."
struct ArgForms
    short::String
    long::String
end

abstract type AbstractValidator end

@kwdef struct StrValidator <: AbstractValidator
    case_sens::Bool = false
    val_list::Vector{String} = []
    reg_ex::Vector{Regex} = []
    start_w::Vector{String} = []
    StrValidator(case_sens, val_list, reg_ex, start_w) = all(isempty.([val_list, reg_ex, start_w])) ? 
        error("StrValidator init error: At least one criterium must be non-empty") :
        new(case_sens, val_list, reg_ex, start_w) 
end

@kwdef struct RealValidator <: AbstractValidator
    excl_vals::Vector{Real} = []
    excl_ivls::Vector{Tuple{Real, Real}} = []
    incl_vals::Vector{Real} = []
    incl_ivls::Vector{Tuple{Real, Real}} = []
    RealValidator(excl_vals, excl_ivls, incl_vals, incl_ivls) = all(isempty.([excl_vals, excl_ivls, incl_vals, incl_ivls])) ? 
        error("RealValidator init error: At least one criterium must be non-empty") :
        new(excl_vals, excl_ivls, incl_vals, incl_ivls) 
end

function validate(v::AbstractString, vl::StrValidator)
    ok = true
    if !vl.case_sens 
        v = uppercase(v)
        v_list = vl.val_list .|> uppercase
        sw_list = vl.start_w  .|> uppercase
    else
        v_list = vl.val_list
        sw_list = vl.start_w 
    end
    v in v_list && return (; ok, v)
    any(occursin.(vl.reg_ex, Ref(v))) && return (; ok, v)
    for sw in sw_list
        startswith(sw, v) && return (; ok, v=sw) # return full word
    end
    return (; ok=false, v=nothing)
end

function validate(v::Real, vl::RealValidator)
    in_interval(v, x) = x[1] <= v <= x[2]

    ok = false
    any([isapprox(v, x) for x in vl.excl_vals]) && return (; ok, v=nothing)
    any(in_interval.(v, vl.excl_ivls)) && return (; ok, v=nothing)

    ok = true
    any([isapprox(v, x) for x in vl.incl_vals]) && return (; ok, v)
    any(in_interval.(v, vl.incl_ivls)) && return (; ok, v) 
    
    return (; ok=false, v=nothing)
end

function vltest(v, ivl)
    return in_interval.(v, ivl)
end
export vltest

validate(v, vl) = error("no method defined for validate($(typeof(v)), $(typeof(vl)))") 

# if no Validator, then no validation performed
validate(v, ::Nothing) = (; ok=true, v)
validate(v::Nothing, ::Nothing) = (; ok=true, v)

validate(v::Nothing, ::Any) = (; ok=true, v) # nothing is generally a valid value

"Command-line argument values."
@kwdef mutable struct ArgumentValues
    const args::ArgForms
    value::Any
    const type::Type = Any
    const required::Bool = false
    const positional::Bool = false
    const description::String = ""
    const validator::Union{AbstractValidator, Nothing} = nothing
end

"Command-line argument parser with key-value stores and attributes."
@kwdef mutable struct ArgumentParser
    # stores
    "key-value store: { key: ArgumentValues(value, type, required, help) }; up to 65,536 argument keys"
    kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()
    "key-value store: { arg: key }"
    arg_store::OrderedDict{String,UInt16} = OrderedDict()
    "number of stored args"
    lng::UInt16 = 0
    # attributes
    "file name"
    filename::String = ""
    "description"
    description::String = ""
    "name of author(s): First Last <first.last@email.address>"
    authors::Vector{String} = String[]
    "URL of documentations"
    documentation::String = ""
    "URL of software repository"
    repository::String = ""
    "name of license"
    license::String = ""
    "usage/help message"
    usage::String = ""
    "usage examples"
    examples::Vector{String} = String[]
    "flag to automatically generate a help message"
    add_help::Bool = false
    "immediately throw on exception if false"
    return_err = false
end

###
### Functions
###

"Extract struct members to vector."
function args2vec(args::ArgForms)
    :Vector
    if isempty(args.short)
        if isempty(args.long)
            return String[]
        end
        return String[args.long]
    elseif isempty(args.long)
        return String[args.short]
    else
        return String[args.short, args.long]
    end
end

"Argument to argument-store key conversion by removing hypenation from prefix."
function arg2key(arg::AbstractString)
    :String
    return lstrip(arg, '-')
end

"Add command-line argument to ArgumentParser object instance."
function add_argument!(parser::ArgumentParser, arg_short::String="", arg_long::String="";
    type::Type=Any, required=false, positional=false, default=nothing, description::String="", validator=nothing)
    """
    # Arguments
    _Mandatory_
    - `parser::ArgumentParser`: ArgumentParser object instance.
    _Optional_
    - `arg_short::String=nothing`: short argument flag.
    - `arg_long::String=nothing`: long argument flag.
    _Keyword_
    - `type::Type=nothing`: argument type.
    - `default::Any=nothing`: default argument value.
    - `required::Bool=false`: whether argument is required.
    - `description::String=nothing`: argument description.
    """
    :ArgumentParser

    args::ArgForms = ArgForms(arg_short, arg_long)
    arg::String = !isempty(arg_long) ? arg_long : !isempty(arg_short) ? arg_short : ""
    isempty(arg) && throw(ArgumentError("Argument(s) missing. See usage examples."))
    parser.lng += 1
    key::UInt16 = parser.lng
    # map both argument names to the same key
    !isempty(arg_short) && (parser.arg_store[arg2key(arg_short)] = key)
    !isempty(arg_long)  && (parser.arg_store[arg2key(arg_long)]  = key)
    default = (type == Any) | isnothing(default) ? default : convert(type, default)
    vals::ArgumentValues = ArgumentValues(args, default, type, required, positional, description, validator)
    validate(default, validator).ok || throw(ArgumentError("invalid default value $default"))
    parser.kv_store[key] = vals
    return parser
end

"Add command-line usage example."
function add_example!(parser::ArgumentParser, example::AbstractString)
    :ArgumentParser
    push!(parser.examples, example)
    return parser
end

"Usage/help message generator."
function generate_usage(parser::ArgumentParser)
    :String
    """example:
    Usage: main.jl --input <PATH> [--verbose] [--problem] [--help]
    
    A Julia script with command-line arguments.
    
    Options:
      -i, --input <PATH>    Path to the input file.
      -v, --verbose         Enable verbose message output.
      -p, --problem         Print the problem statement.
      -h, --help            Print this help message.
    
    Examples:
      \$ julia main.jl --input dir/file.txt --verbose
      \$ julia main.jl --help
    """
    usage::String = "Usage: $(parser.filename)"
    options::String = "Options:"
    for v::ArgumentValues in values(parser.kv_store)
        args_vec::Vector{String} = args2vec(v.args)
        # example: String -> "<STRING>"
        type::String = v.type != Bool ? string(" ", join("<>", uppercase(string(v.type)))) : ""
        # example: (i,input) -> "[-i|--input <STRING>]"
        args_usage::String = string(join(hyphenate.(args_vec), "|"), type)
        !v.required && (args_usage = join("[]", args_usage))
        usage *= string(" ", args_usage)
        # example: (i,input) -> "-i, --input <STRING>"
        tabs::String = v.type != Bool ? "\t" : "\t\t"
        args_options::String = string("\n  ", join(hyphenate.(args_vec), ", "), type, tabs, v.description)
        options *= args_options
    end
    examples::String = string("Examples:", join(string.("\n  \$ ", parser.examples)))
    generated::String = """

    $(usage)

    $(parser.description)

    $(options)

    $(examples)
    """
    return generated
end

"Helper function to print usage/help message."
function help(parser::ArgumentParser; color::AbstractString="default")
    :Nothing
    println(colorize(parser.usage, color=color))
    return nothing
end

"Parse command-line arguments."
function parse_args!(parser::ArgumentParser; cli_args=ARGS)
    :ArgumentParser
    if parser.add_help
        parser = add_argument!(parser, "-h", "--help", type=Bool, default=false, description="Print the help message.")
        parser.usage = generate_usage(parser)
    end
    parser.filename = PROGRAM_FILE
    n::Int64 = length(cli_args)
    for i::Int64 in eachindex(cli_args)
        arg::String = cli_args[i]
        argkey::String = arg2key(arg)
        if startswith(arg, "-")
            !haskey(parser.arg_store, argkey) && return _error(parser.return_err, "Argument not found: $(arg). Call `add_argument` before parsing.")
            key::UInt16 = parser.arg_store[argkey]
            !haskey(parser.kv_store, key) && return _error(parser.return_err, "Key not found for argument: $(arg)"; excp=ErrorException)
        else
            continue
        end
        # if next iteration is at the end or is an argument, treat current argument as flag/boolean
        # otherwise, capture the value and skip iterating over it for efficiency
        if (i + 1 > n) || startswith(cli_args[i+1], "-")
            value = true
        elseif (i + 1 <= n)
            value = cli_args[i+1]
            i += 1
        else
            return _error(parser.return_err, "Value failed to parse for arg: $(arg)")
        end
        # extract default value and update given an argument value
        vals::ArgumentValues = parser.kv_store[key]
        # type cast value into tuple index 1
        value = try
            value = vals.type == Any ? value : _parse(vals.type, value)
        catch e
            e isa ArgumentError && return _error(parser.return_err, "cannot parse $value into $(vals.type)")
        end

        parser.kv_store[key].value = value
    end
    return parser
end

"Get argument value from parser."
function get_value(parser::ArgumentParser, arg::AbstractString)
    :Any
    argkey::String = arg2key(arg)
    !haskey(parser.arg_store, argkey) && return _error(parser.return_err, "Argument not found: $(arg). Run `add_argument` first.")
    key::UInt16 = parser.arg_store[argkey]
    value::Any = haskey(parser.kv_store, key) ? parser.kv_store[key].value : nothing
    return value
end

"Prepend hyphenation back onto argument after stripping it for the argument-store key."
function hyphenate(arg::AbstractString)
    :String
    argkey::String = arg2key(arg)  # supports "foo" or "--foo" argument form
    result::String = length(argkey) == 1 ? "-" * argkey : "--" * argkey
    return result
end

"Set/update value of argument in parser."
function set_value!(parser::ArgumentParser, arg::AbstractString, value::Any)
    :ArgumentParser
    argkey::String = arg2key(arg)
    !haskey(parser.arg_store, argkey) && throw(ArgumentError("Argument not found in store."))
    key::UInt16 = parser.arg_store[argkey]
    !haskey(parser.kv_store, key) && throw(ArgumentError("Key not found in store."))
    vals::ArgumentValues = parser.kv_store[key]
    vld = vals.validator
    value = convert(vals.type, value)
    (ok, value) = validate(value, vld)
    ok || throw(ArgumentError("$value is not a valid argument value"))
    parser.kv_store[key] = ArgumentValues(vals.args, value, vals.type, vals.required, vals.positional, vals.description, vals.validator)
    return parser
end

_error(return_err, x; excp=ArgumentError) = return_err ? excp(x) : throw(excp(x)) 

# Type conversion helper methods.
_parse(x, y) = parse(x, y)
_parse(::Type{String},   x::Number)  = x
_parse(::Type{String},   x::String)  = x
_parse(::Type{Bool},     x::Bool)    = x
_parse(::Type{Number},   x::Number)  = x
_parse(::Type{String},   x::Bool)    = x ? "true" : "false"

###
### Utilities
###

"Key-value store mapping from colors to ANSI codes."
ANSICODES::Base.ImmutableDict{String,Int} = Base.ImmutableDict(
    "black"   => 30,
    "red"     => 31,
    "green"   => 32,
    "yellow"  => 33,
    "blue"    => 34,
    "magenta" => 35,
    "cyan"    => 36,
    "white"   => 37,
    "default" => 39
)

function colorize(text::AbstractString; color::AbstractString="default", background::Bool=false, bright::Bool=false)
    :String
    """
    Colorize strings or backgrounds using ANSI codes and escape sequences.
    -------------------------------------------------------------------------------
    | Color 	Example 	Text 	Background 	  Bright Text   Bright Background |
    | ----------------------------------------------------------------------------|
    | Black 	Black 	    30 	    40 	           90           100               |
    | Red 	    Red 	    31 	    41 	           91           101               |
    | Green 	Green 	    32 	    42 	           92           102               |
    | Yellow 	Yellow 	    33 	    43 	           93           103               |
    | Blue      Blue 	    34 	    44 	           94           104               |
    | Magenta 	Magenta 	35 	    45 	           95           105               |
    | Cyan      Cyan 	    36 	    46 	           96           106               |
    | White 	White 	    37 	    47 	           97           107               |
    | Default 		        39 	    49 	           99           109               |
    -------------------------------------------------------------------------------
    # Arguments
    - `text::String`: the UTF-8/ASCII text to colorize.
    - `color::String="default"`: the standard ANSI name of the color.
    - `background::Bool=false`: flag to select foreground or background color.
    - `bright::Bool=false`: flag to select normal or bright text.
    """
    code::Int8 = ANSICODES[color]
    background && (code += 10)
    bright && (code += 60)
    code_string::String = string(code)
    return "\033[" * code_string * "m" * text * "\033[0m"
end

# # # # # # # # 

function colorprint(text, color="default", newline=true; background=false, bright=false) 
    print(colorize(text; color, background, bright))
    newline && println()
end

argpair(s, parser) = Symbol(s) => get_value(parser, s)

_keys(parser::ArgumentParser) = [arg2key(v.args.long) for v in values(parser.kv_store)]

canonicalname(argf::ArgForms) = lstrip((isempty(argf.long) ? argf.short : argf.long), '-')
canonicalname(argvs::ArgumentValues) = canonicalname(argvs.args)

# probably later move out to GivEmExel
function args_pairs(parser::ArgumentParser; excl=["help", "abort"])
    args = collect(values(parser.kv_store))
    filter!(x -> !isnothing(x.value), args)
    filter!(x -> !(lstrip(x.args.long, '-') in excl) , args)
    return [Symbol(canonicalname(a)) => a.value for a in args]
end

positional_args(parser::ArgumentParser)= [x for x in values(parser.kv_store) if x.positional]

@kwdef mutable struct PromptedParser
    parser::ArgumentParser = ArgumentParser(; return_err=true)
    color::String = "default"
    introduction::String = ""
    prompt::String = "> "
end

args_pairs(p::PromptedParser) = args_pairs(p.parser)
set_value!(p::PromptedParser, arg, value) = set_value!(p.parser, arg, value)
add_argument!(p::PromptedParser, arg_short, arg_long; kwargs...) = add_argument!(p.parser, arg_short, arg_long; kwargs...)
parse_args!(p::PromptedParser, cli_args) = parse_args!(p.parser; cli_args)
add_example!(p::PromptedParser, example) = add_example!(p.parser, example) 
help(p::PromptedParser; color=p.color) = help(p.parser; color)
get_value(p::PromptedParser, arg) = get_value(p.parser, arg)

end # module SimpleArgParse
