#!/usr/bin/env julia

# Example for validating arguments

################

# We check if YAArguParser is installed in the current environment, 
# otherwise we try to switch the environment, or install it into a 
# temporary environment.

try
    using YAArguParser
catch
    using Pkg
    parentdir = (dirname(@__DIR__)) 
    parentdir_name = parentdir |> basename
    if parentdir_name == "YAArguParser.jl"
        println("activating parent dir")
        Pkg.activate(parentdir)
    else
        Pkg.activate(; temp=true)
        Pkg.add("YAArguParser")
    end
end

################

using YAArguParser
using YAArguParser: shell_split

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

    # simulate supplied args
    str = "-p SVG -n 33 --help"
    args = shell_split(str)

    parse_args!(ap; cli_args=args)

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
;
