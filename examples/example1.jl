#!/usr/bin/env julia

# simple use example

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

using YAArguParser: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs, generate_usage!

function main()

    ap = ArgumentParser(description="YAArguParser example.", add_help=true)
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

    # DO SOMETHING ELSE

    return 0
end

main()
;