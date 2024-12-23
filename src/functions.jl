"""
    args2vec(args::ArgForms) → ::Vector{String}

Extract struct members to vector of length 1 or 2.

Function `args2vec` is internal.
"""
args2vec(args::ArgForms) = filter!(x -> !isempty(x), [args.short, args.long])

"""
    arg2strkey(arg::AbstractString) → ::SubString

Argument to argument-store string key conversion by removing hypenation from prefix.

Function `arg2strkey` is internal.
"""
arg2strkey(arg) = lstrip(arg, '-')


"""
    add_argument!(parser::AbstractArgumentParser, arg_short::String="", arg_long::String=""; kwargs...) → Nothing

# Arguments
- `parser::AbstractArgumentParser`: AbstractArgumentParser object instance.
- `arg_short::String=""`: short argument flag.
- `arg_long::String=""`: long argument flag.

# Keywords
- `type::Type=nothing`: type, the argument value to be parsed/converted into.
- `default::Any=nothing`
- `positional::Bool=false`
- `description::String=nothing`
- `validator::Union{AbstractValidator, Nothing}=nothing` 

# Throws
- Throws immediately in case of error, e.g. if a key already present.

Function `add_argument!` is exported
"""
function add_argument!(parser::AbstractArgumentParser, arg_short::String="", arg_long::String="";
    type::Type=Any, positional=false, default=missing, description::String="", validator=nothing)

    args::ArgForms = ArgForms(arg_short, arg_long)
    arg::String = !isempty(arg_long) ? arg_long : !isempty(arg_short) ? arg_short : ""
        isempty(arg) && throw(ArgumentError("Argument(s) missing. See usage examples.")) 

    haskey(parser.arg_store, arg2strkey(arg_short)) && error("Cannot add argument: Key $arg_short already present.")
    haskey(parser.arg_store, arg2strkey(arg_long)) && error("Cannot add argument: Key $arg_short already present.")

    parser.lng += 1
    numkey::UInt16 = parser.lng
    # map both argument names to the same numkey
    !isempty(arg_short) && (parser.arg_store[arg2strkey(arg_short)] = numkey)
    !isempty(arg_long)  && (parser.arg_store[arg2strkey(arg_long)]  = numkey)
    (ok, default) = validate(default, validator)
    ok || throw(ArgumentError("invalid default value $default for arg $(canonicalname(args))")) 
    vals = ArgumentValues(; args, value=default, type, positional, description, validator)
    parser.kv_store[numkey] = vals
    return nothing
end

"""
    add_example!(parser::AbstractArgumentParser, example::AbstractString) → Nothing

Function `add_example!` is exported.
"""
function add_example!(parser::AbstractArgumentParser, example::AbstractString)
    push!(parser.examples, example)
    return Nothing
end

"""
    sort_args(parser::AbstractArgumentParser) → (;pos_args, keyed_args, all_args)

Function `sort_args` is internal.
"""
function sort_args(parser)
    pos_args = ArgumentValues[]
    keyed_args = ArgumentValues[]

    for v in values(parser.kv_store)
        if v.positional
            push!(pos_args, v)
        else
            push!(keyed_args, v)
        end      
    end
    all_args = [pos_args; keyed_args]
    return (;pos_args, keyed_args, all_args)
end

"""
    argument_usage(v::ArgumentValues) → (; u=args_usage, o=options)

Function `argument_usage` is internal.
"""
function argument_usage(v)
    isrequired = isnothing(v.value)
    args_vec::Vector{String} = args2vec(v.args)
    # example: String -> "<String>"
    type::String = v.type != Bool ? string(" ", join("<>", string(v.type))) : ""
    # example: (i,input) -> "[-i|--input <String>]"
    args_usage::String = v.positional ? type : string(join(hyphenate.(args_vec), "|"), type)
    !isrequired && (args_usage = join("[]", args_usage))
    # example: (i,input) -> "-i, --input <String>"
    tabs::String = v.type != Bool ? "\t" : "\t\t"
    args_options::String = string("\n  ", join(hyphenate.(args_vec), ", "), type, tabs, v.description)
    v.positional && (args_options *= "\t (positional arg)")
    options = args_options
    return (; u=args_usage, o=options)
end

"""
    generate_usage!(parser::AbstractArgumentParser) → Nothing

Usage/help message generator. Function `generate_usage!` is public, not exported.

# Example of generated text
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
function generate_usage!(parser::AbstractArgumentParser)
    usage::String = "Usage: $(parser.filename)"
    options::String = "Options:"

    (;all_args) = sort_args(parser)

    for v::ArgumentValues in all_args
        (; u, o) = argument_usage(v)
        usage *= " " * u
        options *= o
    end

    examples::String = string("Examples:", join(string.("\n  \$ ", parser.examples)))
    generated::String = """

    $(usage)

    $(parser.description)

    $(options)

    $(examples)
    """
    parser.usage = generated
    return nothing
end

"""
    help(parser::AbstractArgumentParser; color::Union{AbstractString, Nothing}) → nothing

Print usage/help message. Function `help` is exported.
"""
function help(parser::AbstractArgumentParser; color=nothing)
    color = getcolor(parser, color)
    colorprint(parser.usage, color)
    return nothing
end

"""
    update_val!(parser::AbstractArgumentParser, numkey::Integer, cli_val::Union{AbstractString, Bool}) → ::Union{Nothing, Exception}

See also [`set_value!`](@ref). Function `update_val!` is internal.
"""
function update_val!(parser, numkey, cli_val)
    av::ArgumentValues = parser.kv_store[numkey]
    av.cli_val = string(cli_val)

    (;ok, v, msg) = parse_arg(av) 
    ok || return _error(throw_on_exception(parser), msg)

    return set_value!(parser, numkey, v) # ::Union{Nothing, Exception}
end

"""
    parse_args!(parser::AbstractArgumentParser; cli_args=nothing) →  ::Union{Nothing, Exception}

Parses arguments, validates them and stores the updated values in the parser. 

# Keywords
- `cli_args::Union{Vector{AbstractString}, Nothing}=nothing`: if the `cli_args` not provided, 
    parses the command line arguments `ARGS`. Otherwise accepts equivalent `Vector` of `String`s,
    e.g. `["--foo", "FOO", "-i", "1"]`

# Throws
- `Exception`: depending on the value of `parser.interactive`, in case of non-valid 
    args vector, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `parse_args!` is exported.
"""
function parse_args!(parser::AbstractArgumentParser; cli_args=nothing)
    isnothing(cli_args) && (cli_args=ARGS)
    if parser.add_help 
        haskey(parser, "help") || 
            add_argument!(parser, "-h", "--help", type=Bool, default=false, description="Print the help message.")
        generate_usage!(parser)
    end
    n::Int64 = length(cli_args)
    posargs = positional_args(parser)

    nextarg = 1
    posargs_exhausted = false

    for (i, pa) in pairs(posargs)
        isempty(cli_args) && (posargs_exhausted = true)
        posargs_exhausted || (value = cli_args[i])
        if (!posargs_exhausted && !startswith(value, '-'))
            argkey = canonicalname(pa)
            numkey = parser.arg_store[argkey]
            uv = update_val!(parser, numkey, value)
            uv isa Exception && return uv
            nextarg += 1
        else
            posargs_exhausted = true
            isnothing(pa.value) && return _error(throw_on_exception(parser), "Value for positional argument $(canonicalname(pa)) not supplied")
        end
    end

    skipnext = false
    for i in nextarg:length(cli_args)
        skipnext && (skipnext = false; continue)
        arg = cli_args[i]
        argkey = arg2strkey(arg)
        if startswith(arg, "-")
            !haskey(parser.arg_store, argkey) && return _error(throw_on_exception(parser), "Argument not found: $(arg). Call `add_argument` before parsing.")
            numkey::UInt16 = parser.arg_store[argkey]
            !haskey(parser.kv_store, numkey) && return _error(throw_on_exception(parser), "Key not found for argument: $(arg)"; excp=ErrorException)
        else
            continue
        end
        argtype = parser.kv_store[numkey].type
        isnum = argtype <: Union{AbstractFloat, Signed}
        # if next iteration is at the end or is an argument, treat current argument as flag/boolean
        # otherwise, capture the value and skip next iteration
        if (i + 1 > n) || (startswith(cli_args[i+1], "-") && !isnum)
            value = true
        elseif (i + 1 <= n)
            value = cli_args[i+1]
            skipnext = true
        else
            return _error(throw_on_exception(parser), "Value failed to parse for arg: $(arg)")
        end

        uv = update_val!(parser, numkey, value)
        uv isa Exception && return uv
    end
    return check_missing_input(parser) # ::Union{Nothing, Exception}
end

"""
    check_missing_input(parser::AbstractArgumentParser) → Union{Nothing, Exception}

Checks if all required arguments were supplied. Required is an argument without a default value.  

# Throws
- `Exception`: depending on the value of `throw_on_exception(parser)`, if an argument is 
    missing, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `check_missing_input` is internal.
"""
function check_missing_input(parser)
    args = collect(values(parser.kv_store))
    for x in args
        if ismissing(x.value) 
            # print help and return an error
            help(parser)
            return _error(throw_on_exception(parser), "Required argument $(canonicalname(x)) is missing!")
        end
    end
    return nothing
end

"""
    get_value(parser, arg) → value::Any

Get argument value from parser. 

# Arguments
- `parser::AbstractArgumentParser`: AbstractArgumentParser object instance.
- `arg::AbstractString=""`: argument name, e.g. `"-f"`, `"--foo"`.

# Throws
- `Exception`: depending on the value of `throw_on_exception(parser)`, if the argument not 
    found, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `get_value` is public, not exported.
"""
function get_value(parser::AbstractArgumentParser, arg::AbstractString)
    argkey::String = arg2strkey(arg)
    !haskey(parser.arg_store, argkey) && return _error(throw_on_exception(parser), "Argument not found: $(arg). Run `add_argument` first.")
    numkey::UInt16 = parser.arg_store[argkey]
    value::Any = haskey(parser.kv_store, numkey) ? parser.kv_store[numkey].value : nothing
    return value
end

"""
    hyphenate(argname::AbstractString) → ::String

Prepend hyphenation back onto argument after stripping it for the argument-store numkey.

Function `hyphenate` is internal.
"""
function hyphenate(argname::AbstractString)
    strkey::String = arg2strkey(argname)  # supports "foo" or "--foo" argument form
    result::String = length(strkey) == 1 ? "-" * strkey : "--" * strkey
    return result
end

"""
    set_value!(parser::AbstractArgumentParser, numkey::Integer, value::Any) → ::Union{Nothing, Exception}
    set_value!(parser::AbstractArgumentParser, argname::AbstractString, value::Any) → ::Union{Nothing, Exception}

Set/update value of argument (which is specified by `numkey` or `argname`), validating it, in parser.

# Throws
- `Exception`: depending on the value of `throw_on_exception` , if the argument not 
    found, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `set_value!` is public, not exported.
"""
function set_value!(parser::AbstractArgumentParser, numkey::Integer, value::Any)
    thr_on_exc = throw_on_exception(parser)
    !haskey(parser.kv_store, numkey) && return _error(thr_on_exc, "Key not found in store.")
    vals::ArgumentValues = parser.kv_store[numkey]
    vld = vals.validator
    (ok, value) = validate(value, vld)
    ok || return _error(thr_on_exc, "$value is not a valid value for arg $(canonicalname(vals.args))") 
    parser.kv_store[numkey].value = value
    return nothing
end

function set_value!(parser::AbstractArgumentParser, argname::AbstractString, value::Any)
    thr_on_exc =throw_on_exception(parser)
    strkey = arg2strkey(argname)
    !haskey(parser.arg_store, strkey) && return _error(thr_on_exc, "Argument not found in store.")
    numkey = parser.arg_store[strkey]
    return set_value!(parser, numkey, value)
end

"""
    _error(throw_on_exception, msg::AbstractString; excp=ArgumentError) → ::Exception

Depending on value of `throw_on_exception`, throw immediately, or return `Exception` to be 
processed downstream.

Function `_error` is internal.
"""
_error(thr_on_exc, msg; excp=ArgumentError) = thr_on_exc ? throw(excp(msg)) : excp(msg) 

"""
    parse_arg(av::ArgumentValues) → (; ok, v=parsed_value, msg=nothing)
    parse_arg(t::Type, av::ArgumentValues)
    parse_arg(t::Type, val::Union{AbstractString, Bool}, ::Union{Nothing, AbstractValidator})

Tries to parse `cli_val` to type `t`. For your custom types or custom parsing, provide your own methods. Returns a `NamedTuple` as above.

Function `parse_arg` is public, but not exported.
"""
parse_arg(av::ArgumentValues) = parse_arg(av.type, av)
# now we can dispatch on type

function parse_arg(t::Type, av::ArgumentValues)
    cli_val = av.cli_val
    vld = av.validator
    return parse_arg(t, cli_val, vld)
end

function parse_arg(t::Type, cli_val::AbstractString, ::Any) 
    v = tryparse(t, cli_val)
    isnothing(v) && return (; ok=false, v, msg="cannot parse $cli_val into $t")
    return (; ok=true, v, msg=nothing)
end

# Keyword cli args of Bool type is a special case, 
# as they do not necessary have the "argument body", and then converted explicitely. 
# All other arguments passed as Strings
parse_arg(::Type{Bool}, v::Bool, ::Any) = (; ok=true, v, msg=nothing)
parse_arg(::Type{String},   v::AbstractString, ::Any)  = (; ok=true, v, msg=nothing)
