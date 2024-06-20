
"""
    ArgForms

Command-line arguments, short and long forms. Type `ArgForms` is exported.

# Fields
- `short::String`
- `long::String`
"""
struct ArgForms
    short::String
    long::String
end

"""
    ArgumentValues

Command-line argument values. Type `ArgumentValues` is exported.

# Fields
- `const args::ArgForms`
- `value::Any`
- `const type::Type = Any`
- `const positional::Bool = false`
- `const description::String = ""`
- `const validator::Union{AbstractValidator, Nothing} = nothing`
"""
@kwdef mutable struct ArgumentValues
    const args::ArgForms
    value::Any = missing
    const type::Type = Any
    const positional::Bool = false
    const description::String = ""
    const validator::Union{AbstractValidator, Nothing} = nothing
end

"""
    InteractiveUsage

Type `InteractiveUsage` is exported.

# Fields  
- `throw_on_exception = false`: immediately throw on exception if `true`, 
    or process error downstream if `false` (interactive use)
- `color::String = "default"`: output color (see `colorize` function)
- `introduction::String = ""`: explanation or introduction to be shown before prompt on a separate line
- `prompt::String = "> "`
"""

abstract type AbstractArgumentParser end

"""
    ArgumentParser <: AbstractArgumentParser

Command-line argument parser with numkey-value stores and attributes. Type `AbstractArgumentParser` is exported.

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
- `color::String = "default"`: output color - see also [`ANSICODES`](@ref)
- `interactive::Union{Nothing, InteractiveUsage} = nothing`: interactive usage attributes (see `InteractiveUsage`)
"""
@kwdef mutable struct ArgumentParser <: AbstractArgumentParser
    kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()
    arg_store::OrderedDict{String,UInt16} = OrderedDict()
    lng::UInt16 = 0
    description::String = ""
    filename::String = ""
    usage::String = ""
    examples::Vector{String} = String[]
    add_help::Bool = false
    color::String = "default"
    interactive::Union{Nothing, InteractiveUsage} = nothing
end

@kwdef mutable struct InteractiveArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    throw_on_exception::Bool=false
    introduction::String = ""
    prompt::String = "> "
end


# function argparser(;throw_on_exception=nothing, introduction=nothing, prompt=nothing, kwargs...) 
#     isnothing(throw_on_exception) && isnothing(introduction) && isnothing(prompt) && return ArgumentParser(;kwargs...)
#     return ArgumentParser(;interactive=InteractiveUsage(;throw_on_exception, introduction, prompt), kwargs...)
# end

# export argparser