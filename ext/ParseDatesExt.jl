module ParseDatesExt

using YAArguParser
using YAArguParser: _error, AbstractValidator

using Dates
using OrderedCollections: OrderedDict

import YAArguParser: parse_arg


function tryparse_datetime(type, v, format=nothing)
    isnothing(format) && return tryparse(type, v)
    return tryparse(type, v, DateFormat(format))
end

"""
    parse_datetime(av::ArgumentValues, validator::AbstractValidator)

Parses `v` to `DateTime`, `Date`, or `Time`, depending on `v`. Works for many common formats of date and time representation.

This function is public, not exported, and can be specialized on `validator`, if desired.
"""
parse_datetime(av::ArgumentValues, ::Union{AbstractValidator, Nothing}) = parse_datetime(av.cli_val)

function parse_datetime(v::AbstractString) # 
    formats = OrderedDict(
        Date => [nothing],
        Time => [nothing],
        DateTime => [nothing],
        DateTime => [
        "yyyy-mm-ddTHH:MM:SS",
        "yyyy-mm-ddTHH:MM:SS.s",
        "yyyy-mm-dd HH:MM:SS",
        "yyyy-mm-dd HH:MM:SS.s",
        "yyyy-mm-ddTHH:MM",
        "yyyy-mm-dd_HH:MM",
        "dd.mm.yyyy HH:MM",
        "dd.mm.yyyy HH:MM:SS"
    ],
    Date => [
        "yyyy-mm-dd",
        "dd.mm.yyyy",
    ],
    Time => [
        "HH:MM:SS",
        "HH:MM:SS.s",
        "HH:MM",
    ])

    wrong_formats = [r"^\d{1,2}\.\d{1,2}\.\d{1,2}(?: |$)"]

    for f in wrong_formats
        isnothing(match(f, v)) ||
            return (; ok=false, v=nothing, msg="cannot parse $v into Date or Time: Check if year has four digits")
    end

    for (k, ar) in pairs(formats)
        for f in ar
            x = tryparse_datetime(k, v, f)
            isnothing(x) || return (; ok=true, v=x, msg=nothing)
        end
    end

    return (; ok=false, v=nothing, msg="cannot parse $v into Date or Time")
end

"""
    parse_arg(t::Type{DateTime}, av::ArgumentValues) → (; ok, v::Union{DateTime, Date, Time}=parsed_value, msg=nothing)

Parses `v` to `DateTime`, `Date`, or `Time`, depending on `v`. Works for many common formats of date and time representation.

# Examples
```julia-repl
julia> parse_arg(DateTime, "2024-12-31", nothing)
(ok = true, v = Date("2024-12-31"), msg = nothing)

julia> parse_arg(DateTime, "17:18:19", nothing)
(ok = true, v = Time(17, 18, 19), msg = nothing)

julia> parse_arg(DateTime, "31.12.2024 17:18", nothing)
(ok = true, v = DateTime("2024-12-31T17:18:00"), msg = nothing)
```
"""
parse_arg(t::Type{DateTime}, av::ArgumentValues) = parse_datetime(av, av.validator) 
parse_arg(t::Type{DateTime}, v::AbstractString, ::Any) = parse_datetime(v) # this is just for testing

end # module ParseDatesExt