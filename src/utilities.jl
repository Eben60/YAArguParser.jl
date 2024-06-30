"""
Key-value store mapping from colors to ANSI codes. 
For color table, see help to internal [`colorize`](@ref) function. 
    
An internal constant.
"""
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

"""
    colorize(text; color, background, bright) → ::String

Colorize strings or backgrounds using ANSI codes and escape sequences.

| Color    | Text| Background| Bright text| Bright background |
| ---------|-----|-----------|------------|-------------------|
| Black    | 30  | 40        | 90         | 100               |
| Red      | 31  | 41        | 91         | 101               |
| Green    | 32  | 42        | 92         | 102               |
| Yellow   | 33  | 43        | 93         | 103               |
| Blue     | 34  | 44        | 94         | 104               |
| Magenta  | 35  | 45        | 95         | 105               |
| Cyan     | 36  | 46        | 96         | 106               |
| White    | 37  | 47        | 97         | 107               |
| Default  | 39  | 49        | 99         | 109               |

# Arguments
- `text::AbstractString`: the UTF-8/ASCII text to colorize.

# Keywords
- `color::AbstractString="default"`: the standard ANSI name of the color.
- `background::Bool=false`: flag to select foreground or background color.
- `bright::Bool=false`: flag to select normal or bright text.

Function `colorize` is internal.
"""
function colorize(text::AbstractString; color::AbstractString="default", background::Bool=false, bright::Bool=false)
    code::Int8 = ANSICODES[color]
    background && (code += 10)
    bright && (code += 60)
    code_string::String = string(code)
    return "\033[" * code_string * "m" * text * "\033[0m"
end

"""
    getcolor(parser::AbstractArgumentParser, color=nothing)  → color::String

Returns `color` in case second arg is defined, otherwise the color defined in `parser`, or "default".

Function `getcolor` is public, not exported.
"""
function getcolor(parser::AbstractArgumentParser, color=nothing) 
    !isnothing(color) && return color   
    return isnothing(parser.color) ? 
        "default" : parser.color
end

"""
    colorprint(text, color::AbstractString="default", newline=true; background=false, bright=false) → nothing
    colorprint(text, parser::AbstractArgumentParser, newline=true; background=false, bright=false) → nothing

Print colored text into stdout. For color table, see help to internal [`colorize`](@ref) function. 
If second arg is an `AbstractArgumentParser`, uses color as defined within, if any, otherwise uses `default`.

Function `colorprint` is exported.
"""
function colorprint(text, color="default", newline=true; background=false, bright=false) 
    print(colorize(text; color, background, bright))
    newline && println()
end

colorprint(text, parser::AbstractArgumentParser, newline=true; background=false, bright=false) = 
    colorprint(text, getcolor(parser), newline; background, bright)

argpair(s, parser) = Symbol(s) => get_value(parser, s)

_keys(parser::AbstractArgumentParser) = [arg2strkey(v.args.long) for v in values(parser.kv_store)]

canonicalname(argf::ArgForms) = lstrip((isempty(argf.long) ? argf.short : argf.long), '-')
canonicalname(argvs::ArgumentValues) = canonicalname(argvs.args)

"""
    args_pairs(parser::AbstractArgumentParser; excl::Union{Nothing, Vector{String}}=nothing) → ::Vector{Pair{Symbol, Any}}

Return vector of pairs `argname => argvalue` for all arguments except listed in `excl`.
    If argument has both short and long forms, the long one is used. Returned value can 
    be e.g. passed as `kwargs...` to a function processing the parsed data, converted to 
    a `Dict` or `NamedTuple`.

Function `args_pairs` is exported.
"""
function args_pairs(parser::AbstractArgumentParser; excl=nothing)
    isnothing(excl) && (excl=[])
    args = collect(values(parser.kv_store))
    filter!(x -> !isnothing(x.value), args)
    filter!(x -> !(lstrip(x.args.long, '-') in excl) , args)
    return [Symbol(canonicalname(a)) => a.value for a in args]
end

positional_args(parser::AbstractArgumentParser) = [x for x in values(parser.kv_store) if x.positional]

throw_on_exception(::Nothing) = true
function throw_on_exception(p::AbstractArgumentParser)
    hasproperty(p, :throw_on_exception) && return p.throw_on_exception
    return true
end

"""
    haskey(parser::AbstractArgumentParser, key::AbstractString) → ::Bool
    haskey(parser::AbstractArgumentParser, key::Integer) → ::Bool
"""
Base.haskey(parser::AbstractArgumentParser, key::AbstractString) = haskey(parser.arg_store, arg2strkey(key))   
Base.haskey(parser::AbstractArgumentParser, key::Integer) = haskey(parser.kv_store, key)

getnestedparsers(p::AbstractArgumentParser) = [getfield(p, f) for f in fieldnames(typeof(p)) if getfield(p, f) isa AbstractArgumentParser]

function Base.hasproperty(p::AbstractArgumentParser, s::Symbol)
    hasfield(typeof(p), s) && return true
    for np in getnestedparsers(p)
        hasproperty(np, s) && return true
    end
    return false
end

function Base.getproperty(p::AbstractArgumentParser, s::Symbol)
    hasfield(typeof(p), s) && return getfield(p, s)
    for np in getnestedparsers(p)
        hasproperty(np, s) && return getproperty(np, s)
    end
    return error("type $(typeof(p)) has no property $s")
end

function Base.setproperty!(p::AbstractArgumentParser, s::Symbol, x)
    if hasfield(typeof(p), s) 
        T = typeof(getfield(p, s))
        return setfield!(p, s, convert(T, x))
    end
    for np in getnestedparsers(p)
        hasproperty(np, s) && return setproperty!(np, s, x)
    end
    return error("type $(typeof(p)) has no property $s")
end

function Base.propertynames(p::AbstractArgumentParser, private::Bool=false)
    pns = Symbol[]
    for f in fieldnames(typeof(p))
        push!(pns, f)
        pp = getproperty(p, f)
        pp isa AbstractArgumentParser && append!(pns, propertynames(pp))
    end
    allunique(pns) || error("$(typeof(p)) has nonunique fields $(symdiff(pns, unique(pns)))")
    return Tuple(pns)
end


"""
    shell_split(s::AbstractString) → String[]

Split a string into a vector of args.

`shell_split` is in internal function of `Base`, accessible as a public function of `SimpleArgParse2` e.g. 
by `using SimpleArgParse2: shell_split`.

# Examples
```julia-repl
julia> shell_split("--foo 3 -b bar")
4-element Vector{String}:
 "--foo"
 "3"
 "-b"
 "bar"
```
"""
function shell_split end
