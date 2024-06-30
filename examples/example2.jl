#!/usr/bin/env julia

# Customized help example

# somehow we have to ensure that SimpleArgParse2 is installed in the current environment, 
# otherwise try to switch the environment
using Pkg

if ! haskey(Pkg.dependencies(), "SimpleArgParse2")
    simpleargparse_dir = dirname(@__DIR__)
    Pkg.activate(simpleargparse_dir)
end

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
;