
"Command-line arguments."
struct ArgForms
    short::String
    long::String
end


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
