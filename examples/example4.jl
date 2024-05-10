#!/usr/bin/env julia

# Example for:
# - positional arguments
# - custom validator
# - interactive application


# Start this example from terminal: 
# it wouldn't work from REPL

# Somehow we have to ensure that SimpleArgParse is installed in the current environment, 
# otherwise try to switch the environment

using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse")
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

using Dates
using SimpleArgParse
using SimpleArgParse: AbstractValidator
import SimpleArgParse: validate

@kwdef struct FullAgeValidator <: AbstractValidator
    legal_age::Int = 18
end

function validate(v::Union{AbstractString, Date}, vl::FullAgeValidator)
    birthdate = today()
    try
        birthdate = Date(v)
    catch
        return (; ok=false, v=nothing)
    end

    d = day(birthdate)
    m = month(birthdate)
    fullageyear = year(birthdate) + vl.legal_age

    Date(fullageyear, m, d) > today() && return (; ok=false, v=nothing)

    return (; ok=true, v=birthdate)
end

function askandget(pp; color=pp.color)
    colorprint(pp.interactive.introduction, color)
    colorprint(pp.interactive.prompt, color, false)
    answer = readline()
    cli_args = Base.shell_split(answer)
    parse_args!(pp; cli_args)
    r = NamedTuple(args_pairs(pp))
    # needhelp = get(r, :help, false)
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

    ask_full_age  = let
        pp = ArgumentParser(; 
            description="Asking if one is of full age", 
            add_help=true, 
            color = color,
            interactive=InteractiveUsage(;
                throw_on_exception = true,
                introduction="Are you of full legal age? Please type y[es] or n[o] and press <ENTER>",
                prompt=prompt,
                ),       
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
        
        add_example!(pp, "$(pp.interactive.prompt) y")
        add_example!(pp, "$(pp.interactive.prompt) --abort")
        add_example!(pp, "$(pp.interactive.prompt) --help")
        pp
    end

    check_full_age  = let
        pp = ArgumentParser(; 
            description="Checking if one is of full age", 
            add_help=true, 
            color=color, 
            interactive=InteractiveUsage(;
                throw_on_exception = true,
                introduction="Please enter your birth date in the yyyy-mm-dd format",
                prompt=prompt,
                ),       
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
        
        add_example!(pp, "$(pp.interactive.prompt) 2000-02-29")
        add_example!(pp, "$(pp.interactive.prompt) --abort")
        add_example!(pp, "$(pp.interactive.prompt) --help")
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
