

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
    isnothing(default) && positional && !required && 
        error("Error adding argument for $arg_long, $arg_short. Optional positional argument must have a valid default value")    

    haskey(parser.arg_store, arg2key(arg_short)) && error("Cannot add argument: Key $arg_short already present.")
    haskey(parser.arg_store, arg2key(arg_long)) && error("Cannot add argument: Key $arg_short already present.")

    parser.lng += 1
    key::UInt16 = parser.lng
    # map both argument names to the same key
    !isempty(arg_short) && (parser.arg_store[arg2key(arg_short)] = key)
    !isempty(arg_long)  && (parser.arg_store[arg2key(arg_long)]  = key)
    default = (type == Any) | isnothing(default) ? default : convert(type, default)
    (ok, default) = validate(default, validator)
    ok || throw(ArgumentError("invalid default value $default"))
    vals::ArgumentValues = ArgumentValues(args, default, type, required, positional, description, validator)
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

function update_val!(parser, key, value)
    # extract default value and update given an argument value
    vals::ArgumentValues = parser.kv_store[key]
    # type cast value into tuple index 1
    value = try
        value = vals.type == Any ? value : _parse(vals.type, value)
    catch e
        e isa ArgumentError && return _error(parser.return_err, "cannot parse $value into $(vals.type)")
    end

    return set_value!(parser, key, value; return_err = parser.return_err)
end

"Parse command-line arguments."
function parse_args!(parser::ArgumentParser; cli_args=ARGS)
    :ArgumentParser
    cli_args = copy(cli_args)
    if parser.add_help
        parser = add_argument!(parser, "-h", "--help", type=Bool, default=false, description="Print the help message.")
        parser.usage = generate_usage(parser)
    end
    parser.filename = PROGRAM_FILE
    n::Int64 = length(cli_args)
    posargs = positional_args(parser)

    nextarg = 1
    posargs_exhausted = false

    for (i, pa) in pairs(posargs)
        isempty(cli_args) && (posargs_exhausted = true)
        posargs_exhausted || (value = cli_args[i])
        if (!posargs_exhausted && !startswith(value, '-'))
            argkey = canonicalname(pa)
            key = parser.arg_store[argkey]
            uv = update_val!(parser, key, value)
            uv isa Exception && return uv
            nextarg += 1
        else
            posargs_exhausted = true
            (isnothing(pa.value) | pa.required) && return _error(parser.return_err, "Value for positional argument $(canonicalname(pa)) not supplied")
        end
    end

    for i::Int64 in nextarg:length(cli_args)
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
        uv = update_val!(parser, key, value)
        uv isa Exception && return uv
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
function set_value!(parser::ArgumentParser, key::Integer, value::Any; return_err = false)
    !haskey(parser.kv_store, key) && return _error(return_err, "Key not found in store.")
    vals::ArgumentValues = parser.kv_store[key]
    vld = vals.validator
    value = convert(vals.type, value)
    (ok, value) = validate(value, vld)
    ok || return _error(return_err, "$value is not a valid argument value")
    parser.kv_store[key] = ArgumentValues(vals.args, value, vals.type, vals.required, vals.positional, vals.description, vals.validator)
    return parser
end

function set_value!(parser::ArgumentParser, arg::AbstractString, value::Any; return_err = false)
    :ArgumentParser
    argkey::String = arg2key(arg)
    !haskey(parser.arg_store, argkey) && return _error(return_err, "Argument not found in store.")
    key::UInt16 = parser.arg_store[argkey]
    return set_value!(parser::ArgumentParser, key::Integer, value::Any)
end

_error(return_err, x; excp=ArgumentError) = return_err ? excp(x) : throw(excp(x)) 

# Type conversion helper methods.
_parse(x, y) = parse(x, y)
_parse(::Type{String},   x::Number)  = x
_parse(::Type{String},   x::String)  = x
_parse(::Type{Bool},     x::Bool)    = x
_parse(::Type{Number},   x::Number)  = x
_parse(::Type{String},   x::Bool)    = x ? "true" : "false"
