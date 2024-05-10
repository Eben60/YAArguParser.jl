#!/usr/bin/env julia

# Example for validating arguments

# somehow we have to ensure that SimpleArgParse is installed in the current environment, 
# otherwise try to switch the environment

using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse")
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

fname = splitpath(@__FILE__)[end]

using SimpleArgParse

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
    
    add_example!(ap, "$fname -n 1 --plotformat NONE")
    add_example!(ap, "$fname -n 1")
    add_example!(ap, "$fname --help")

    parse_args!(ap)

    # get all arguments as NamedTuple
    args = NamedTuple(args_pairs(ap))

    # print the usage/help message in color defined during initialization, if asked for help
    args.help && help(ap)

    # display the arguments
    println(args)

    # DO SOMETHING AMAZING

    return ap
end

main()
;
