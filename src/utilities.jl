const COLORS = ["black","red","green","yellow","blue","magenta","cyan","white"]

function colorsymbol(color; bright=false)
    cs = string(color)
    cs in ["normal", "default"] && return Symbol(cs)
    cs in COLORS || error("Color $cs not available. Available colors are $COLORS and \"default\"")
    return bright ? Symbol("light_$cs") : Symbol(cs)
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
    colorprint(text, color::Union{AbstractString, Symbol}="default", newline=true; background=false, 
        bright=false, bold=false, italic=false, underline=false, blink=false) → nothing
    colorprint(text, parser::AbstractArgumentParser, newline=true; kwargs...) → nothing

Print colored/styled text into stdout, provided the terminal supports it. Available colors are 
`"black"`, `"red"`, `"green"`, `"yellow"`, `"blue"`, `"magenta"`, `"cyan"`, `"white"`, and `"default"`.
If second arg is an `AbstractArgumentParser`, uses color as defined within, if any, otherwise uses `"default"`.

Function `colorprint` is exported.
"""
function colorprint(text, color="default", newline=true; background=false, 
    bright=false, bold=false, italic=false, underline=false, blink=false) 
    cs = colorsymbol(color; bright)
    printstyled(text; color=cs, bold, italic, underline, blink, reverse=background)
    newline && println()
end

colorprint(text, parser::AbstractArgumentParser, newline=true; kwargs...) = 
    colorprint(text, getcolor(parser), newline; kwargs...)

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
    haskey(parser::AbstractArgumentParser, key::AbstractString) → 
    haskey(parser::AbstractArgumentParser, key::Integer) → 
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

function Base.propertynames(p::AbstractArgumentParser, private=false)
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

`shell_split` is in internal function of `Base`, accessible as a public function of `YAArguParser` e.g. 
by `using YAArguParser: shell_split`.

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
