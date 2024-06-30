## Installation

As usual, e.g.
```julia
] add SimpleArgParse2
```

## Specification

We approximate the [Microsoft command-line syntax](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/command-line-syntax-key). Optional arguments are surrounded by square brackets, values are surrounded by angle brackets (chevrons), and mutually exclusive items are separated by a vertical bar. 

## Usage

Apart from these usage examples (you find the complete sources in the`./examples` folder), we suggest you also check the the testsuite `./test/runtests.jl` .

### Example 1 - common usage

We first create an `ArgumentParser` object, then add and parse our command-line arguments. We will automagically generate a `usage` string from our key-value store of command-line arguments here, but is also possible to write your own help message instead. 

```julia
using SimpleArgParse2: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs, generate_usage!

function main()

    ap = ArgumentParser(description="SimpleArgParse2 example.", add_help=true)
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia $(ap.filename) --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia $(ap.filename) --help")

    parse_args!(ap)

    # get all arguments as NamedTuple
    args = NamedTuple(args_pairs(ap))

    # print the usage/help message in magenta if asked for help
    args.help && help(ap, color="magenta")

    # display the arguments
    println(args)

    # DO SOMETHING AMAZING

    return 0
end

main()
```

That is about as simple as it gets and closely follows Python's [`argparse`](https://docs.python.org/3/library/argparse.html). 

### Example 2 - customized help

Now let's define a customized help message:

```julia
using SimpleArgParse2

const usage = raw"""
  Usage: main.jl --input <PATH> [--verbose] [--problem] [--help]

  A Julia script with command-line arguments.

  Options:
    -i, --input <PATH>    Path to the input file.
    -v, --verbose         Enable verbose message output.
    -p, --problem         Print the problem statement.
    -h, --help            Print this help message.

  Examples:
    $ julia main.jl --input dir/file.txt --verbose
    $ julia main.jl --help
"""

function main()

    ap = ArgumentParser(description="SimpleArgParse2 example.", add_help=true, color="cyan")
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia $(ap.filename) --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia $(ap.filename) --help")

    # add usage/help text from above
    ap.usage = usage

    parse_args!(ap)

    # print the usage/help message in color defined in ap
    help(ap)

    # DO SOMETHING ELSE

    return 0
end

main()
```

### Example 3 - validating arguments

Now, with validating supplied arguments (read [Types](@ref) Docstrings section for Validator details):

```julia
using SimpleArgParse2

function main()

    ap = ArgumentParser(; 
        description="Command line options parser", 
        add_help=true, 
        color = "cyan", 
        )

    add_argument!(ap, "-p", "--plotformat"; 
        type=String, 
        default="PNG",
        description="Accepted file format: PNG (default), PDF, SVG or NONE", 
        validator=StrValidator(; upper_case=true, patterns=["PNG", "SVG", "PDF", "NONE"]),
        )

    add_argument!(ap, "-n", "--number"; 
        type=Int, 
        # an argument with a default value is optional, without - required 
        # default=nothing,
        description="an integer value ranging from 0 to 42", 
        validator=RealValidator{Int}(; incl_ivls=[(0, 42)]),
        )
    
    add_example!(ap, "$(ap.filename) -n 1 --plotformat NONE")
    add_example!(ap, "$(ap.filename) -n 1")
    add_example!(ap, "$(ap.filename) --help")

    parse_args!(ap)

    # get all arguments as NamedTuple
    args = NamedTuple(args_pairs(ap))

    # print the usage/help message in color defined during initialization, if asked for help
    args.help && help(ap)

    # display the arguments
    println(args)

    # DO SOMETHING with args

    return ap
end

main()
```

### Example 4 - custom parser, `initparser`

This example shows how to create a customized parser. Here, we create `LegacyArgumentParser` type which is equivalent to `ArgumentParser` 
of [`SimpleArgParse`](https://github.com/admercs/SimpleArgParse.jl). You see that by making our type a subtype of 
[`AbstractArgumentParser`](@ref SimpleArgParse2.AbstractArgumentParser) we achieve a flattened access to the `struct` properties.
This is used by [`initparser`](@ref SimpleArgParse2.initparser) function, which simplifies initilalization of nested structs.

```julia
using SimpleArgParse2
using SimpleArgParse2: AbstractArgumentParser

@kwdef mutable struct LegacyArgumentParser <: AbstractArgumentParser
    ap::ArgumentParser = ArgumentParser()
    authors::Vector{String} = String[]
    documentation::String = ""
    repository::String = ""
    license::String = ""
end

lp = initparser(LegacyArgumentParser; license="MIT", authors=["Eben60"], description="Example how to extend an argument parser")
@assert lp.ap.description == lp.description
```

### Example 5 - positional arguments, custom validator, `initparser`

```julia
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
```

