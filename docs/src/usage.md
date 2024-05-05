## Installation

As usual
```julia
] add SimpleArgParse
```

## Specification

We approximate the [Microsoft command-line syntax](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/command-line-syntax-key). Optional arguments are surrounded by square brackets, values are surrounded by angle brackets (chevrons), and mutually exclusive items are separated by a vertical bar. Simple!

## Usage

We first create an `ArgumentParser` object, then add and parse our command-line arguments. We will automagically generate a `usage` string from our key-value store of command-line arguments here, but is also possible to write your own help message instead. 

```julia
using SimpleArgParse: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs, generate_usage!

function main()

    ap = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia example2.jl --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia example2.jl --help")
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

```

That is about as simple as it gets and closely follows Python's [`argparse`](https://docs.python.org/3/library/argparse.html). 

See other examples in the ./examples folder for extended usage.
