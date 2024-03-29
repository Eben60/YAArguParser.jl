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

validate(v, vl) = error("no method defined for validate($(typeof(v)), $(typeof(vl)))") 

# if no Validator, then no validation performed
validate(v, ::Nothing) = (; ok=true, v)
validate(v::Nothing, ::Nothing) = (; ok=true, v)

validate(v::Nothing, ::Any) = (; ok=true, v) # nothing is generally a valid value
