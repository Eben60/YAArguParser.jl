
"""
    ArgForms

Command-line arguments, short and long forms. 

# Fields
- `short::String`
- `long::String`

Type `ArgForms` is exported.
"""
struct ArgForms
    short::String
    long::String
end

"""
    ArgumentValues

Command-line argument values. 

# Fields
- `const args::ArgForms`
- `value_str::String = ""`
- `value::Any`
- `const type::Type = Any`
- `const positional::Bool = false`
- `const description::String = ""`
- `const validator::Union{AbstractValidator, Nothing} = nothing`

Type `ArgumentValues` is exported.
"""
@kwdef mutable struct ArgumentValues
    const args::ArgForms
    value_str::String = ""
    value::Any = missing
    const type::Type = Any
    const positional::Bool = false
    const description::String = ""
    const validator::Union{AbstractValidator, Nothing} = nothing
end

# (; args, value_str, value, type, positional, description, validator)

"""
    abstract type AbstractArgumentParser

The supertype for argument parser types. `Base` functions `hasproperty`, `getproperty`, `setproperty!`, and `propertynames` have overloaded methods
for `AbstractArgumentParser`, providing a flattened view onto nested structs. See also [`initparser`](@ref).

Type `AbstractArgumentParser`  is public, but not exported.

# Examples
```julia-repl
julia> @kwdef mutable struct MyAP <: AbstractArgumentParser
       ap::ArgumentParser=ArgumentParser()
       foo::Bool=false
       end
MyAP

julia> x = MyAP(ap=ArgumentParser(; color="magenta"); foo=true);

julia> x.foo
true

julia> x.ap.color
"magenta"

julia> x.color
"magenta"
``` 
"""
abstract type AbstractArgumentParser end

"""
    ArgumentParser <: AbstractArgumentParser

Command-line argument parser with numkey-value stores and attributes. 

# Fields
## stores
- `kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()`: `numkey => value` 
- `arg_store::OrderedDict{String,UInt16} = OrderedDict()`: numkey-value store: `arg => numkey`
- `lng::UInt16 = 0`: counter of stored args
## attributes
- `description::String = ""`: description
- `usage::String = ""`: The script name passed to Julia from the command line.
- `usage::String = ""`: usage/help message
- `examples::Vector{String} = String[]`: usage examples
- `add_help::Bool = false`: flag to automatically generate a help message
- `color::String = "default"`: output color - for color table, see help to [`colorprint`](@ref) function.

Type `ArgumentParser` is exported
"""
@kwdef mutable struct ArgumentParser <: AbstractArgumentParser
    kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()
    arg_store::OrderedDict{String,UInt16} = OrderedDict()
    lng::UInt16 = 0
    description::String = ""
    filename::String = PROGRAM_FILE
    usage::String = ""
    examples::Vector{String} = String[]
    add_help::Bool = false
    color::String = "default"
end

"""
    InteractiveArgumentParser <: AbstractArgumentParser

Extension of `ArgumentParser` for interactive use. 

# Fields
- `ap::ArgumentParser = ArgumentParser()`
- `throw_on_exception = false`: cause to immediately throw on exception if `true`, 
    vs. processing error downstream if `false` (interactive use)
- `introduction::String = ""`: explanation or introduction to be shown before prompt on a separate line
- `prompt::String = "> "`

Type `InteractiveArgumentParser` is exported.
"""
@kwdef mutable struct InteractiveArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    throw_on_exception::Bool=false
    introduction::String = ""
    prompt::String = "> "
end

"""
    initparser(AP::::Type{AbstractArgumentParser}, strict=true; kwargs...) →  ::AbstractArgumentParser

Initializes a parser. First a parser of `AP` type with default values is created, then it's properties set 
to the values provided by `kwargs`. With `strict` flag set, checks if every `kwarg` 
corresponds to an `AP` property, otherwise ignore those without correspondence.

`initparser` is a syntactic sugar to "normal" struct initialization, making use of the flattened view onto 
nested structs , as provided by overloading of property functions for [`AbstractArgumentParser`](@ref).

# Throws
- `ErrorException`: if supplied with kwargs having no corresponding `AP` .

Function `initparser` is exported.

# Examples
```julia-repl
julia> initparser(InteractiveArgumentParser; description="blablabla", color="magenta", add_help=true, throw_on_exception=true)
InteractiveArgumentParser(ArgumentParser(OrderedCollections.OrderedDict{UInt16, ArgumentValues}(), OrderedCollections.OrderedDict{String, UInt16}(), 0x0000, "blablabla", "", "", String[], true, "magenta"), true, "", "> ")
``` 
"""
function initparser(AP, strict=true; kwargs...)
    p = AP()
    propertynames(p) # will check if all AP fields are unique
    for (k, v) in kwargs
        if hasproperty(p, k)
            setproperty!(p, k, v)
        elseif strict
            error("$AP has no property $k")
        end
    end
    return p
end
