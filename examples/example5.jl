#!/usr/bin/env julia

# Example for:
# - positional arguments
# - custom validator
# - interactive application

#   ! ! 
# Start this example from terminal: 
# it wouldn't work from REPL

################

# We check if SimpleArgParse2 is installed in the current environment, 
# otherwise we try to switch the environment.

using Pkg, UUIDs

pkg_name = "SimpleArgParse2"
pkg_uuid = UUID("e3fa765b-3027-4ef3-bb12-e639c1e60c6e")

pkg_available = ! isnothing(Pkg.Types.Context().env.pkg) && Pkg.Types.Context().env.pkg.name == pkg_name
pkg_available = pkg_available || haskey(Pkg.dependencies(), pkg_uuid)

if ! pkg_available
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

################

using Dates
using SimpleArgParse2
using SimpleArgParse2: AbstractValidator, warn_and_return
import SimpleArgParse2: validate

@kwdef struct FullAgeValidator <: AbstractValidator
    legal_age::Int = 18
end

function validate(v::Union{AbstractString, Date}, vl::FullAgeValidator)
    birthdate = today()
    try
        birthdate = Date(v)
    catch
        return warn_and_return(v)
    end

    d = day(birthdate)
    m = month(birthdate)
    fullageyear = year(birthdate) + vl.legal_age

    Date(fullageyear, m, d) > today() && return warn_and_return(v)

    return (; ok=true, v=birthdate)
end

function askandget(pp; color=pp.color)
    colorprint(pp.introduction, color)
    colorprint(pp.prompt, color, false)
    answer = readline()
    cli_args = Base.shell_split(answer)
    parse_args!(pp; cli_args)
    r = NamedTuple(args_pairs(pp))
    if r.help
        help(pp)
        exit()
    end
    r.abort && exit()
    return r
end

function main()

    color = "cyan"
    prompt = "legal age check> "

    ask_full_age = let
        pp = initparser(InteractiveArgumentParser;  
            description="Asking if one is of full age", 
            add_help=true, 
            color = color,
            introduction="Are you of full legal age? Please type y[es] or n[o] and press <ENTER>",
            throw_on_exception = true,
            prompt=prompt,
            )

        add_argument!(pp, "-y", "--yes_no"; 
            type=String, 
            positional=true,
            description="Asking about legal age",
            validator=StrValidator(; upper_case=true, starts_with=true, patterns=["yes", "no"]),
            )
    
        add_argument!(pp, "-a", "--abort", 
            type=Bool, 
            default=false,
            description="Abort?",
            )   
        
        add_example!(pp, "$(pp.prompt) y")
        add_example!(pp, "$(pp.prompt) --abort")
        add_example!(pp, "$(pp.prompt) --help")
        pp
    end

    check_full_age = let
        pp = initparser(InteractiveArgumentParser; 
            description="Checking if one is of full age", 
            add_help=true, 
            color=color, 
            throw_on_exception = true,
            introduction="Please enter your birth date in the yyyy-mm-dd format",
            prompt=prompt,
            )

        add_argument!(pp, "-d", "--birthdate"; 
            type=Date, 
            positional=true,
            description="Asking about legal age",
            validator=FullAgeValidator(),
            )
    
        add_argument!(pp, "-a", "--abort", 
            type=Bool, 
            default=false, 
            description="Abort?",
            )   
        
        add_example!(pp, "$(pp.prompt) 2000-02-29")
        add_example!(pp, "$(pp.prompt) --abort")
        add_example!(pp, "$(pp.prompt) --help")
        pp
    end

    (; yes_no ) = askandget(ask_full_age)
    yes = yes_no == "YES"
    yes || return false

    (; birthdate) = askandget(check_full_age )
    println("You appear to be of full age.")

    return true
end

main()
;