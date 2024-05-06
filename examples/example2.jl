#!/usr/bin/env julia

# somehow we have to ensure that SimpleArgParse is installed in the current environment, 
# otherwise try to switch the environment
using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse")
    simpleargparse__dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse__dir)
end
using SimpleArgParse

fname = splitpath(@__FILE__)[end]

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

    ap = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia $fname --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia $fname --help")

    # add usage/help text from above
    ap.usage = usage

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