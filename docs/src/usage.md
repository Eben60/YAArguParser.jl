## Installation

As usual, e.g.
```julia
] add SimpleArgParse
```

## Specification

We approximate the [Microsoft command-line syntax](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/command-line-syntax-key). Optional arguments are surrounded by square brackets, values are surrounded by angle brackets (chevrons), and mutually exclusive items are separated by a vertical bar. Simple!

## Usage

We first create an `ArgumentParser` object, then add and parse our command-line arguments. We will automagically generate a `usage` string from our key-value store of command-line arguments here, but is also possible to write your own help message instead. 

```julia
using SimpleArgParse: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs

fname = splitpath(@__FILE__)[end]
function main()

    ap = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(ap, "julia $fname --input dir/file.txt --number 10 --verbose")
    add_example!(ap, "julia $fname --help")

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

Now let's define a customized help message:

```julia
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

    ap = ArgumentParser(description="SimpleArgParse example.", add_help=true, color="cyan")
    add_argument!(ap, "-h", "--help", type=Bool, default=false, description="Help switch.")
    add_argument!(ap, "-i", "--input", type=String, default="filename.txt", description="Input file.")
    add_argument!(ap, "-n", "--number", type=Int, default=0, description="Integer number.")
    add_argument!(ap, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")

    # add usage/help text from above
    ap.usage = usage

    parse_args!(ap)

    # print the usage/help message in color defined in ap
    help(ap)

    return 0
end

main();
```

Now, with validating supplied arguments (read [Types](@ref) Docstrings section for Validator details):

```julia

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
        description="an integer value ranging from 0 to 42", 
        validator=RealValidator{Int}(; incl_ivls=[(0, 42)]),
        )

    parse_args!(ap)

    args = NamedTuple(args_pairs(ap))

    # DO SOMETHING AMAZING with args

    return nothing
```

See usage examples in the `./examples` folder as well the testsuite `./test/runtests.jl` .
