
@kwdef mutable struct PromptedParser
    parser::ArgumentParser = ArgumentParser(; throw_on_exception=false)
    color::String = "default"
    introduction::String = ""
    prompt::String = "> "
end

args_pairs(p::PromptedParser) = args_pairs(p.parser)
set_value!(p::PromptedParser, arg, value) = set_value!(p.parser, arg, value)
add_argument!(p::PromptedParser, arg_short, arg_long; kwargs...) = add_argument!(p.parser, arg_short, arg_long; kwargs...)
parse_args!(p::PromptedParser, cli_args) = parse_args!(p.parser; cli_args)
add_example!(p::PromptedParser, example) = add_example!(p.parser, example) 
help(p::PromptedParser; color=p.color) = help(p.parser; color)
get_value(p::PromptedParser, arg) = get_value(p.parser, arg)