"Key-value store mapping from colors to ANSI codes."
ANSICODES::Base.ImmutableDict{String,Int} = Base.ImmutableDict(
    "black"   => 30,
    "red"     => 31,
    "green"   => 32,
    "yellow"  => 33,
    "blue"    => 34,
    "magenta" => 35,
    "cyan"    => 36,
    "white"   => 37,
    "default" => 39
)

function colorize(text::AbstractString; color::AbstractString="default", background::Bool=false, bright::Bool=false)
    :String
    """
    Colorize strings or backgrounds using ANSI codes and escape sequences.
    -------------------------------------------------------------------------------
    | Color 	Example 	Text 	Background 	  Bright Text   Bright Background |
    | ----------------------------------------------------------------------------|
    | Black 	Black 	    30 	    40 	           90           100               |
    | Red 	    Red 	    31 	    41 	           91           101               |
    | Green 	Green 	    32 	    42 	           92           102               |
    | Yellow 	Yellow 	    33 	    43 	           93           103               |
    | Blue      Blue 	    34 	    44 	           94           104               |
    | Magenta 	Magenta 	35 	    45 	           95           105               |
    | Cyan      Cyan 	    36 	    46 	           96           106               |
    | White 	White 	    37 	    47 	           97           107               |
    | Default 		        39 	    49 	           99           109               |
    -------------------------------------------------------------------------------
    # Arguments
    - `text::String`: the UTF-8/ASCII text to colorize.
    - `color::String="default"`: the standard ANSI name of the color.
    - `background::Bool=false`: flag to select foreground or background color.
    - `bright::Bool=false`: flag to select normal or bright text.
    """
    code::Int8 = ANSICODES[color]
    background && (code += 10)
    bright && (code += 60)
    code_string::String = string(code)
    return "\033[" * code_string * "m" * text * "\033[0m"
end

# # # # # # # # 

function colorprint(text, color="default", newline=true; background=false, bright=false) 
    print(colorize(text; color, background, bright))
    newline && println()
end

argpair(s, parser) = Symbol(s) => get_value(parser, s)

_keys(parser::ArgumentParser) = [arg2key(v.args.long) for v in values(parser.kv_store)]

canonicalname(argf::ArgForms) = lstrip((isempty(argf.long) ? argf.short : argf.long), '-')
canonicalname(argvs::ArgumentValues) = canonicalname(argvs.args)

# probably later move out to GivEmExel
function args_pairs(parser::ArgumentParser; excl=["help", "abort"])
    args = collect(values(parser.kv_store))
    filter!(x -> !isnothing(x.value), args)
    filter!(x -> !(lstrip(x.args.long, '-') in excl) , args)
    return [Symbol(canonicalname(a)) => a.value for a in args]
end

positional_args(parser::ArgumentParser)= [x for x in values(parser.kv_store) if x.positional]
