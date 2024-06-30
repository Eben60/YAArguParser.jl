using SimpleArgParse2
using SimpleArgParse2: get_value, set_value!

function main()
    :Int

    args::ArgumentParser = ArgumentParser(description="SimpleArgParse2 example.", add_help=true)
    add_argument!(args, "-i", "--input", type=String, default="filename.txt", description="Input file.") # required=true, 
    add_argument!(args, "-n", "--number", type=UInt8, default=0, description="Integer number.")
    add_argument!(args, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    add_example!(args, "julia main.jl --input dir/file.txt --number 10 --verbose")
    add_example!(args, "julia main.jl --help")
    parse_args!(args)
    
    # check boolean flags passed via command-line
    get_value(args, "verbose") && println("Verbose mode enabled")
    get_value(args, "v")       && println("Verbose mode enabled")
    get_value(args, "--help")  && help(args, color="yellow")

    # check values
    haskey(args, "input")  && println("Input file: ", get_value(args, "input"))  # has_key no more
    haskey(args, "number") && println("The number: ", get_value(args, "number"))

    # we can override the usage statement with our own
    args.usage::String = "\nUsage: main.jl [--input <PATH>] [--verbose] [--problem] [--help]"
    help(args, color="cyan")
    
    # use `set` to override command-line argument values
    haskey(args, "help") && set_value!(args, "help", true) # has_key no more
    haskey(args, "help") && help(args, color="green")

    # check if SHA-256 byte key exists and print it if it does
    # hash no more used
    # get_key no more

    # DO SOMETHING AMAZING

    return 0
end

main()
