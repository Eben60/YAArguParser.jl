#!/usr/bin/env julia

# somehow we have to ensure that SimpleArgParse is installed in the current environment, 
# otherwise try to switch the environment
using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse")
    simpleargparse__dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse__dir)
end

fname = splitpath(@__FILE__)[end]

using SimpleArgParse: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs, generate_usage!

function main()

    ap = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia $fname --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia $fname --help")
    generate_usage!(ap)

    ap = parse_args!(ap)

    # get all arguments as NamedTuple
    args = NamedTuple(args_pairs(ap))

    # print the usage/help message in magenta if asked for help
    args.help && help(ap, color="magenta")

    # display the arguments
    println(args)

    # DO SOMETHING AMAZING

    return 0
end

main();