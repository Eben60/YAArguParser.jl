var documenterSearchIndex = {"docs":
[{"location":"usage.html#Installation","page":"Usage","title":"Installation","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"As usual, e.g.","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"] add SimpleArgParse","category":"page"},{"location":"usage.html#Specification","page":"Usage","title":"Specification","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"We approximate the Microsoft command-line syntax. Optional arguments are surrounded by square brackets, values are surrounded by angle brackets (chevrons), and mutually exclusive items are separated by a vertical bar. Simple!","category":"page"},{"location":"usage.html#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage.html#Example-1-common-usage","page":"Usage","title":"Example 1 - common usage","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"We first create an ArgumentParser object, then add and parse our command-line arguments. We will automagically generate a usage string from our key-value store of command-line arguments here, but is also possible to write your own help message instead. ","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"using SimpleArgParse: ArgumentParser, add_argument!, add_example!, help, parse_args!, args_pairs\n\nfname = splitpath(@__FILE__)[end]\nfunction main()\n\n    ap = ArgumentParser(description=\"SimpleArgParse example.\", add_help=true)\n    add_argument!(ap, \"-h\", \"--help\", type=Bool, default=false, description=\"Help switch.\")\n    add_argument!(ap, \"-i\", \"--input\", type=String, default=\"filename.txt\", description=\"Input file.\")\n    add_argument!(ap, \"-n\", \"--number\", type=Int, default=0, description=\"Integer number.\")\n    add_argument!(ap, \"-v\", \"--verbose\", type=Bool, default=false, description=\"Verbose mode switch.\")\n    add_example!(ap, \"julia $fname --input dir/file.txt --number 10 --verbose\")\n    add_example!(ap, \"julia $fname --help\")\n\n    parse_args!(ap)\n\n    # get all arguments as NamedTuple\n    args = NamedTuple(args_pairs(ap))\n\n    # print the usage/help message in magenta if asked for help\n    args.help && help(ap, color=\"magenta\")\n\n    # display the arguments\n    println(args)\n\n    # DO SOMETHING AMAZING\n\n    return 0\nend\n\nmain()","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"That is about as simple as it gets and closely follows Python's argparse. ","category":"page"},{"location":"usage.html#Example-2-customized-help","page":"Usage","title":"Example 2 - customized help","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"Now let's define a customized help message:","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"const usage = raw\"\"\"\n  Usage: main.jl --input <PATH> [--verbose] [--problem] [--help]\n\n  A Julia script with command-line arguments.\n\n  Options:\n    -i, --input <PATH>    Path to the input file.\n    -v, --verbose         Enable verbose message output.\n    -p, --problem         Print the problem statement.\n    -h, --help            Print this help message.\n\n  Examples:\n    $ julia main.jl --input dir/file.txt --verbose\n    $ julia main.jl --help\n\"\"\"\n\nfunction main()\n\n    ap = ArgumentParser(description=\"SimpleArgParse example.\", add_help=true, color=\"cyan\")\n    add_argument!(ap, \"-h\", \"--help\", type=Bool, default=false, description=\"Help switch.\")\n    add_argument!(ap, \"-i\", \"--input\", type=String, default=\"filename.txt\", description=\"Input file.\")\n    add_argument!(ap, \"-n\", \"--number\", type=Int, default=0, description=\"Integer number.\")\n    add_argument!(ap, \"-v\", \"--verbose\", type=Bool, default=false, description=\"Verbose mode switch.\")\n\n    # add usage/help text from above\n    ap.usage = usage\n\n    parse_args!(ap)\n\n    # print the usage/help message in color defined in ap\n    help(ap)\n\n    return 0\nend\n\nmain();","category":"page"},{"location":"usage.html#Example-3-validating-arguments","page":"Usage","title":"Example 3 - validating arguments","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"Now, with validating supplied arguments (read Types Docstrings section for Validator details):","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"\nusing SimpleArgParse\n\nfunction main()\n\n    ap = ArgumentParser(; \n        description=\"Command line options parser\", \n        add_help=true, \n        color = \"cyan\", \n        )\n\n    add_argument!(ap, \"-p\", \"--plotformat\"; \n        type=String, \n        default=\"PNG\",\n        description=\"Accepted file format: PNG (default), PDF, SVG or NONE\", \n        validator=StrValidator(; upper_case=true, patterns=[\"PNG\", \"SVG\", \"PDF\", \"NONE\"]),\n        )\n\n    add_argument!(ap, \"-n\", \"--number\"; \n        type=Int, \n        description=\"an integer value ranging from 0 to 42\", \n        validator=RealValidator{Int}(; incl_ivls=[(0, 42)]),\n        )\n\n    parse_args!(ap)\n\n    args = NamedTuple(args_pairs(ap))\n\n    # DO SOMETHING AMAZING with args\n\n    return nothing\nend\n\nmain()","category":"page"},{"location":"usage.html#Example-4-positional-arguments,-custom-validator","page":"Usage","title":"Example 4 - positional arguments, custom validator","text":"","category":"section"},{"location":"usage.html","page":"Usage","title":"Usage","text":"using Dates\nusing SimpleArgParse\nusing SimpleArgParse: AbstractValidator\nimport SimpleArgParse: validate\n\n@kwdef struct FullAgeValidator <: AbstractValidator\n    legal_age::Int = 18\nend\n\nfunction validate(v::Union{AbstractString, Date}, vl::FullAgeValidator)\n    birthdate = today()\n    try\n        birthdate = Date(v)\n    catch\n        return (; ok=false, v=nothing)\n    end\n\n    d = day(birthdate)\n    m = month(birthdate)\n    fullageyear = year(birthdate) + vl.legal_age\n\n    Date(fullageyear, m, d) > today() && return (; ok=false, v=nothing)\n\n    return (; ok=true, v=birthdate)\nend\n\nfunction askandget(pp; color=pp.color)\n    colorprint(pp.interactive.introduction, color)\n    colorprint(pp.interactive.prompt, color, false)\n    answer = readline()\n    cli_args = Base.shell_split(answer)\n    parse_args!(pp; cli_args)\n    r = NamedTuple(args_pairs(pp))\n    # needhelp = get(r, :help, false)\n    if r.help\n        help(pp)\n        exit()\n    end\n    r.abort && exit()\n    return r\nend\n\nfunction main()\n\n    color = \"cyan\"\n    prompt = \"legal age check> \"\n\n    ask_full_age  = let\n        pp = ArgumentParser(; \n            description=\"Asking if one is of full age\", \n            add_help=true, \n            color = color,\n            interactive=InteractiveUsage(;\n                throw_on_exception = true,\n                introduction=\"Are you of full legal age? Please type y[es] or n[o] and press <ENTER>\",\n                prompt=prompt,\n                ),       \n            )\n\n        add_argument!(pp, \"-y\", \"--yes_no\"; \n            type=String, \n            positional=true,\n            description=\"Asking about legal age\",\n            validator=StrValidator(; upper_case=true, starts_with=true, patterns=[\"yes\", \"no\"]),\n            )\n    \n        add_argument!(pp, \"-a\", \"--abort\", \n            type=Bool, \n            default=false,\n            description=\"Abort?\",\n            )   \n        \n        add_example!(pp, \"$(pp.interactive.prompt) y\")\n        add_example!(pp, \"$(pp.interactive.prompt) --abort\")\n        add_example!(pp, \"$(pp.interactive.prompt) --help\")\n        pp\n    end\n\n    check_full_age  = let\n        pp = ArgumentParser(; \n            description=\"Checking if one is of full age\", \n            add_help=true, \n            color=color, \n            interactive=InteractiveUsage(;\n                throw_on_exception = true,\n                introduction=\"Please enter your birth date in the yyyy-mm-dd format\",\n                prompt=prompt,\n                ),       \n            )\n\n        add_argument!(pp, \"-d\", \"--birthdate\"; \n            type=Date, \n            positional=true,\n            description=\"Asking about legal age\",\n            validator=FullAgeValidator(),\n            )\n    \n        add_argument!(pp, \"-a\", \"--abort\", \n            type=Bool, \n            default=false, \n            description=\"Abort?\",\n            )   \n        \n        add_example!(pp, \"$(pp.interactive.prompt) 2000-02-29\")\n        add_example!(pp, \"$(pp.interactive.prompt) --abort\")\n        add_example!(pp, \"$(pp.interactive.prompt) --help\")\n        pp\n    end\n\n    (; yes_no ) = askandget(ask_full_age)\n    yes = yes_no == \"YES\"\n    yes || return false\n\n    (; birthdate) = askandget(check_full_age )\n    println(\"You appear to be of full age.\")\n\n    return true\nend\n\nmain()","category":"page"},{"location":"usage.html","page":"Usage","title":"Usage","text":"See usage examples in the ./examples folder as well the testsuite ./test/runtests.jl .","category":"page"},{"location":"afterword.html#Changelog","page":"Changelog, Related packages, Licence","title":"Changelog","text":"","category":"section"},{"location":"afterword.html#Release-2.0.0","page":"Changelog, Related packages, Licence","title":"Release 2.0.0","text":"","category":"section"},{"location":"afterword.html#Breaking-changes","page":"Changelog, Related packages, Licence","title":"Breaking changes","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Renamed exported mutating functions, e.g. add_example => add_example!.\nLimited the number of exported functions.\nHashmap keys no more used, therefore get_key function removed.\nRemoved has_key function - use haskey instead.\nRemoved required field of ArgumentParser: If a default value provided, then argument is obviously optional, otherwise considered required.\nAnything forgotten? - Please open an issue 🙂  ","category":"page"},{"location":"afterword.html#New-features","page":"Changelog, Related packages, Licence","title":"New features","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Support for (extensible) validators (example).\nSupport for positional arguments (example).\nSupport for use from console apps (example).\nThe added function args_pairs returns pairs argname => argvalue for all arguments at once.\nAnything else?...","category":"page"},{"location":"afterword.html#Other-changes","page":"Changelog, Related packages, Licence","title":"Other changes","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Precompile package using PrecompileTools.jl to improve startup time.\nGeneral code refactoring.\nMade use of public keyword introduced in the coming Julia v1.11.\nTest suite extended and now includes Aqua.jl testing, too.\nExtensive Documenter.jl-based documentation you are reading now.\nExamples added.","category":"page"},{"location":"afterword.html#Release-1.1.0","page":"Changelog, Related packages, Licence","title":"Release 1.1.0","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Switched the hashmap keys to a simple counter, resulting in faster execution. ","category":"page"},{"location":"afterword.html#Release-1.0.0","page":"Changelog, Related packages, Licence","title":"Release 1.0.0","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Changed hashmap key from 8-bit to 16-bit to reduce collision likelihood.\nAdded a usage/help message generator method.\nAdded the add_example, generate_usage, help, haskey, and getkey methods.\nAdded a single dependency, OrderedCollections::OrderedDict, to ensure correctness of argument parsing order.\nSquashed bugs in argument type parsing and conversion.\nAdded test cases.\nAdded examples.","category":"page"},{"location":"afterword.html#Release-0.1.0","page":"Changelog, Related packages, Licence","title":"Release 0.1.0","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"Initial launch :rocket:","category":"page"},{"location":"afterword.html#Related-packages","page":"Changelog, Related packages, Licence","title":"Related packages","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"The popular ArgParse offers much of the same functionality and more.\nThe package GivEmExel relies heavily onto SimpleArgParse and has been the stimulus for the development of SimpleArgParse v2","category":"page"},{"location":"afterword.html#License","page":"Changelog, Related packages, Licence","title":"License","text":"","category":"section"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"MIT License","category":"page"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"[Julia]: http://julialang.org","category":"page"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"[docs-img]: https://img.shields.io/badge/docs-stable-blue.svg [docs-url]: https://github.com/admercs/SimpleArgParse.jl","category":"page"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"[codecov-img]: https://codecov.io/gh/admercs/SimpleArgParse.jl/branch/master/graph/badge.svg [codecov-url]: https://codecov.io/gh/admercs/SimpleArgParse.jl","category":"page"},{"location":"afterword.html","page":"Changelog, Related packages, Licence","title":"Changelog, Related packages, Licence","text":"[CI-img]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml/badge.svg [CI-url]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml","category":"page"},{"location":"index.html#Prefaces","page":"Prefaces","title":"Prefaces","text":"","category":"section"},{"location":"index.html#From-Preface-to-v.1","page":"Prefaces","title":"From Preface to v.1","text":"","category":"section"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Started hackable, single-file, 320-line Julia package for command-line argument parsing, SimpleArgParse offering 95% of the functionality of  ArgParse using ~10% of the lines-of-code (LOC).","category":"page"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Does this need to be more complicated?","category":"page"},{"location":"index.html#Motivation","page":"Prefaces","title":"Motivation","text":"","category":"section"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Parsing command-line arguments should not be complicated. Metaprogramming features such as macros and generators, while cool, are overkill. I wanted a simple command-line argument parsing library in the spirit of Python's argparse, but could not find one. The closest thing I found was ArgParse, but I desired something even simpler. There's nothing worse than having to security audit a massive package for a simple task.","category":"page"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Here it is, a single, simple, 320-line file with one dependency (OrderedCollections::OrderedDict), a single nested data structure, and a few methods. Hack on it, build on it, and use it for your own projects. You can read all of the source code in around one minute.","category":"page"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Enjoy! 😎","category":"page"},{"location":"index.html#Preface-to-v.2","page":"Prefaces","title":"Preface to v.2","text":"","category":"section"},{"location":"index.html","page":"Prefaces","title":"Prefaces","text":"Now, at nearly 600 LOC, not counting tests, divided into several files, the package grew but is still much smaller than ArgParse. The code has been substantially refactored, and features for interactive use in console applications and an extensible input validator has been added. See Changelog for details.","category":"page"},{"location":"docstrings.html#Types","page":"Docstrings","title":"Types","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"Modules = [SimpleArgParse]\nOrder   = [:type, ]","category":"page"},{"location":"docstrings.html#SimpleArgParse.AbstractValidator","page":"Docstrings","title":"SimpleArgParse.AbstractValidator","text":"AbstractValidator\n\nThe supertype for validators. Type AbstractValidator is public, but not exported.\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.ArgForms","page":"Docstrings","title":"SimpleArgParse.ArgForms","text":"ArgForms\n\nCommand-line arguments, short and long forms. Type ArgForms is exported.\n\nFields\n\nshort::String\nlong::String\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.ArgumentParser","page":"Docstrings","title":"SimpleArgParse.ArgumentParser","text":"ArgumentParser\n\nCommand-line argument parser with numkey-value stores and attributes. Type ArgumentParser is exported.\n\nFields\n\nstores\n\nkv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict(): numkey => value \narg_store::OrderedDict{String,UInt16} = OrderedDict(): numkey-value store: arg => numkey\nlng::UInt16 = 0: counter of stored args\n\nattributes\n\nfilename::String = \"\": file name\ndescription::String = \"\": description\nauthors::Vector{String} = String[]: name of author(s): First Last <first.last@email.address>\ndocumentation::String = \"\": URL of documentations\nrepository::String = \"\": URL of software repository\nlicense::String = \"\": name of license\nusage::String = \"\": usage/help message\nexamples::Vector{String} = String[]: usage examples\nadd_help::Bool = false: flag to automatically generate a help message\ninteractive::Union{Nothing, InteractiveUsage} = nothing: interactive usage attributes (see InteractiveUsage)\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.ArgumentValues","page":"Docstrings","title":"SimpleArgParse.ArgumentValues","text":"ArgumentValues\n\nCommand-line argument values. Type ArgumentValues is exported.\n\nFields\n\nconst args::ArgForms\nvalue::Any\nconst type::Type = Any\nconst positional::Bool = false\nconst description::String = \"\"\nconst validator::Union{AbstractValidator, Nothing} = nothing\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.InteractiveUsage","page":"Docstrings","title":"SimpleArgParse.InteractiveUsage","text":"InteractiveUsage\n\nType InteractiveUsage is exported.\n\nFields\n\nthrow_on_exception = false: immediately throw on exception if true,    or process error downstream if false (interactive use)\ncolor::String = \"default\": output color (see colorize function)\nintroduction::String = \"\": explanation or introduction to be shown before prompt on a separate line\nprompt::String = \"> \"\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.RealValidator","page":"Docstrings","title":"SimpleArgParse.RealValidator","text":"RealValidator{T} <: AbstractValidator\n\nNumbers validator type. If no include criteria specified, anything not excluded considered OK.  The intervals are evaluated as closed a ≤ x ≤ b. Type RealValidator is exported.\n\nFields\n\nexcl_vals::Vector{T} = T[]: list of values to exclude\nexcl_ivls::Vector{Tuple{T, T}} = Tuple{T, T}[]: list of intervals to exclude\nincl_vals::Vector{T} = T[]: list of accepted values\nincl_ivls::Vector{Tuple{T, T}} = Tuple{T, T}[]: list of accepted intervals\n\nExamples\n\njulia> validate(1, RealValidator{Int}(;excl_vals=[1, 2], excl_ivls=[(10, 15), (20, 25)], incl_vals=[3, 4, 11], incl_ivls=[(100, 1000)]))\n(ok = false, v = nothing)\n\njulia> validate(150, RealValidator{Int}(;incl_ivls=[(100, 200)]))\n(ok = true, v = 150)\n\njulia> validate(50, RealValidator{Int}(;excl_ivls=[(100, 200)]))\n(ok = true, v = 50)\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#SimpleArgParse.StrValidator","page":"Docstrings","title":"SimpleArgParse.StrValidator","text":"StrValidator <: AbstractValidator\n\nString validator type. Type StrValidator is exported.\n\nFields\n\nupper_case::Bool = false: If true, input and pattern converted to uppercase,    except for regex comparison\nstarts_with::Bool = false: If true, validate if one of the words in the patterns   starts with input. Returns the whole matching word.\npatterns::Vector{Union{AbstractString, Regex}}\n\nExamples\n\njulia> validate(\"foo\", StrValidator(; upper_case=true, patterns=[\"foo\", \"bar\"]))\n(ok = true, v = \"FOO\")\n\njulia> validate(\"foo\", StrValidator(; patterns=[r\"^fo[aoe]$\"]))\n(ok = true, v = \"foo\")\n\njulia> validate(\"ye\", StrValidator(; upper_case=true, starts_with=true, patterns=[\"yes\", \"no\"]))\n(ok = true, v = \"YES\")\n\n\n\n\n\n","category":"type"},{"location":"docstrings.html#Functions","page":"Docstrings","title":"Functions","text":"","category":"section"},{"location":"docstrings.html#Exported-functions","page":"Docstrings","title":"Exported functions","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"add_argument!\nadd_example!\nargs_pairs\ncolorprint\nhaskey\nhelp\nparse_args!\nshell_split\nvalidate","category":"page"},{"location":"docstrings.html#SimpleArgParse.add_argument!","page":"Docstrings","title":"SimpleArgParse.add_argument!","text":"add_argument!(parser::ArgumentParser, arg_short::String=\"\", arg_long::String=\"\"; kwargs...) → parser\n\nArguments\n\nparser::ArgumentParser: ArgumentParser object instance.\narg_short::String=\"\": short argument flag.\narg_long::String=\"\": long argument flag.\n\nKeywords\n\ntype::Type=nothing: type, the argument value to be parsed/converted into.\ndefault::Any=nothing\npositional::Bool=false\ndescription::String=nothing\nvalidator::Union{AbstractValidator, Nothing}=nothing \n\nFunction add_argument! is exported\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.add_example!","page":"Docstrings","title":"SimpleArgParse.add_example!","text":"add_example!(parser::ArgumentParser, example::AbstractString) → parser\n\nFunction add_example! is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.args_pairs","page":"Docstrings","title":"SimpleArgParse.args_pairs","text":"args_pairs(parser::ArgumentParser; excl::Union{Nothing, Vector{String}}=nothing) → ::Vector{Pair{Symbol, Any}}\n\nReturn vector of pairs argname => argvalue for all arguments except listed in excl.     If argument has both short and long forms, the long one is used. Returned value can      be e.g. passed as kwargs... to a function processing the parsed data, converted to      a Dict or NamedTuple.\n\nFunction args_pairs is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.colorprint","page":"Docstrings","title":"SimpleArgParse.colorprint","text":"colorprint(text, color::AbstractString=\"default\", newline=true; background=false, bright=false) → nothing\ncolorprint(text, parser::ArgumentParser, newline=true; background=false, bright=false) → nothing\n\nPrint colored text into stdout. For color table, see help to internal colorize function.  If second arg is an ArgumentParser, uses color as defined within, if any, otherwise uses default.\n\nFunction colorprint is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#Base.haskey","page":"Docstrings","title":"Base.haskey","text":"haskey(parser::ArgumentParser, key::AbstractString) → ::Bool\nhaskey(parser::ArgumentParser, key::Integer) → ::Bool\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.help","page":"Docstrings","title":"SimpleArgParse.help","text":"help(parser::ArgumentParser; color::Union{AbstractString, Nothing}) → nothing\n\nPrint usage/help message. Function help is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.parse_args!","page":"Docstrings","title":"SimpleArgParse.parse_args!","text":"parse_args!(parser::ArgumentParser; cli_args=nothing) → ::Union{ArgumentParser, Exception}\n\nParses arguments, validates them and stores the updated values in the parser. \n\nKeywords\n\ncli_args::Union{Vector{AbstractString}, Nothing}=nothing: if the cli_args not provided,    parses the command line arguments ARGS. Otherwise accepts equivalent Vector of Strings,   e.g. [\"--foo\", \"FOO\", \"-i\", \"1\"]\n\nThrows\n\nException: depending on the value of parser.interactive, in case of non-valid    args vector, the function will either throw imediately, or return e <: Exception to be    processed downstream.\n\nFunction parse_args! is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#Base.shell_split","page":"Docstrings","title":"Base.shell_split","text":"shell_split(s::AbstractString) → String[]\n\nSplit a string into a vector of args.\n\nshell_split is in internal function of Base. It is re-exported.\n\nExamples\n\njulia> shell_split(\"--foo 3 -b bar\")\n4-element Vector{String}:\n \"--foo\"\n \"3\"\n \"-b\"\n \"bar\"\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.validate","page":"Docstrings","title":"SimpleArgParse.validate","text":"validate(v::Any, ::Nothing) → (;ok=true, v)\nvalidate(v::Missing, ::Any) → (;ok=true, v)\nvalidate(v::Any, vl::AbstractValidator) → (;ok::Bool, v)\n\nValidate input v against validator vl, and returns named tuple with validation result ok  and (possibly canonicalized) input value v on success, or nothing on validation failure.  If nothing is supplied instead of Validator, validation skipped. The same, if the value v to be validated is nothing. For examples and specific information see documentation for the corresponding Validator, e.g. StrValidator or RealValidator. Function validate is exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#Public-functions","page":"Docstrings","title":"Public functions","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"SimpleArgParse.generate_usage!\nSimpleArgParse.get_value\nSimpleArgParse.getcolor\nSimpleArgParse.parse_arg\nSimpleArgParse.set_value!","category":"page"},{"location":"docstrings.html#SimpleArgParse.generate_usage!","page":"Docstrings","title":"SimpleArgParse.generate_usage!","text":"generate_usage!(parser::ArgumentParser) → ::String\n\nUsage/help message generator. Function generate_usage! is public, not exported.\n\nExample of generated text\n\nUsage: main.jl –input <PATH> [–verbose] [–problem] [–help]\n\nA Julia script with command-line arguments.\n\nOptions:   -i, –input <PATH>    Path to the input file.   -v, –verbose         Enable verbose message output.   -p, –problem         Print the problem statement.   -h, –help            Print this help message.\n\nExamples:   $ julia main.jl –input dir/file.txt –verbose   $ julia main.jl –help\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.get_value","page":"Docstrings","title":"SimpleArgParse.get_value","text":"get_value(parser, arg) → value::Any\n\nGet argument value from parser. \n\nArguments\n\nparser::ArgumentParser: ArgumentParser object instance.\narg::AbstractString=\"\": argument name, e.g. \"-f\", \"--foo\".\n\nThrows\n\nException: depending on the value of throw_on_exception(parser), if the argument not    found, the function will either throw imediately, or return e <: Exception to be    processed downstream.\n\nFunction get_value is public, not exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.getcolor","page":"Docstrings","title":"SimpleArgParse.getcolor","text":"getcolor(parser::ArgumentParser, color=nothing)  → color::String\n\nReturns color in case second arg is defined, otherwise the color defined in parser, or \"default\".\n\nFunction getcolor is public, not exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.parse_arg","page":"Docstrings","title":"SimpleArgParse.parse_arg","text":"parse_arg(t::Type, val_str::Union{AbstractString, Bool}, ::Union{Nothing, AbstractValidator}) → (; ok, v=parsed_value, msg=nothing)\n\nTries to parse val_str to type t. For your custom types or custom parsing, provide your own methods.\n\nFunction parse_arg is public, but not exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#SimpleArgParse.set_value!","page":"Docstrings","title":"SimpleArgParse.set_value!","text":"set_value!(parser::ArgumentParser, numkey::Integer, value::Any) → parser\nset_value!(parser::ArgumentParser, argname::AbstractString, value::Any) → parser\n\nSet/update value of argument, validating it, as specified by numkey or argname, in parser.\n\nThrows\n\nException: depending on the value of throw_on_exception , if the argument not    found, the function will either throw imediately, or return e <: Exception to be    processed downstream.\n\nFunction set_value! is public, not exported.\n\n\n\n\n\n","category":"function"},{"location":"docstrings.html#Internal-functions","page":"Docstrings","title":"Internal functions","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"Modules = [SimpleArgParse]\nOrder   = [:function]\nFilter = t -> !any(occursin.([\"add_argument!\",\n    \"add_example!\",\n    \"args_pairs\",\n    \"colorprint\",\n    \"haskey\",\n    \"help\",\n    \"parse_args!\",\n    \"shell_split\",\n    \"validate\",\n    \"generate_usage!\",\n    \"get_value\",\n    \"getcolor\",\n    \"parse_arg\",\n    \"set_value!\",], Ref(string(nameof(t)))))","category":"page"},{"location":"docstrings.html#SimpleArgParse._error-Tuple{Any, Any}","page":"Docstrings","title":"SimpleArgParse._error","text":"_error(throw_on_exception, msg::AbstractString; excp=ArgumentError) → ::Exception\n\nDepending on value of throw_on_exception, throw immediately, or return Exception to be  processed downstream.\n\nFunction _error is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.arg2strkey-Tuple{Any}","page":"Docstrings","title":"SimpleArgParse.arg2strkey","text":"arg2strkey(arg::AbstractString) → ::SubString\n\nArgument to argument-store string key conversion by removing hypenation from prefix.\n\nFunction arg2strkey is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.args2vec-Tuple{ArgForms}","page":"Docstrings","title":"SimpleArgParse.args2vec","text":"args2vec(args::ArgForms) → ::Vector{String}\n\nExtract struct members to vector of length 1 or 2.\n\nFunction args2vec is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.argument_usage-Tuple{Any}","page":"Docstrings","title":"SimpleArgParse.argument_usage","text":"argument_usage(v::ArgumentValues) → (; u=args_usage, o=options)\n\nFunction argument_usage is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.check_missing_input-Tuple{Any}","page":"Docstrings","title":"SimpleArgParse.check_missing_input","text":"check_missing_input(parser::ArgumentParser) → (;ok::Bool, err::Union{Nothing, Exception})\n\nChecks if all required arguments were supplied. Required is an argument without a default value.  \n\nThrows\n\nException: depending on the value of throw_on_exception(parser), if an argument is    missing, the function will either throw imediately, or return e <: Exception to be    processed downstream.\n\nFunction check_missing_input is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.colorize-Tuple{AbstractString}","page":"Docstrings","title":"SimpleArgParse.colorize","text":"colorize(text; color, background, bright) → ::String\n\nColorize strings or backgrounds using ANSI codes and escape sequences.\n\nColor Example Text Background Bright text Bright background\nBlack Black 30 40 90 100\nRed Red 31 41 91 101\nGreen Green 32 42 92 102\nYellow Yellow 33 43 93 103\nBlue Blue 34 44 94 104\nMagenta Magenta 35 45 95 105\nCyan Cyan 36 46 96 106\nWhite White 37 47 97 107\nDefault  39 49 99 109\n\nArguments\n\ntext::AbstractString: the UTF-8/ASCII text to colorize.\n\nKeywords\n\ncolor::AbstractString=\"default\": the standard ANSI name of the color.\nbackground::Bool=false: flag to select foreground or background color.\nbright::Bool=false: flag to select normal or bright text.\n\nFunction colorize is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.hyphenate-Tuple{AbstractString}","page":"Docstrings","title":"SimpleArgParse.hyphenate","text":"hyphenate(argname::AbstractString) → ::String\n\nPrepend hyphenation back onto argument after stripping it for the argument-store numkey.\n\nFunction hyphenate is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.sort_args-Tuple{Any}","page":"Docstrings","title":"SimpleArgParse.sort_args","text":"sort_args(parser::ArgumentParser) → (;pos_args, keyed_args, all_args)\n\nFunction sort_args is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#SimpleArgParse.update_val!-Tuple{Any, Any, Any}","page":"Docstrings","title":"SimpleArgParse.update_val!","text":"update_val!(parser::ArgumentParser, numkey::Integer, val_str::AbstractString) → parser\n\nSee also set_value!. Function update_val! is internal.\n\n\n\n\n\n","category":"method"},{"location":"docstrings.html#Constants","page":"Docstrings","title":"Constants","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"Modules = [SimpleArgParse]\nOrder   = [:constant, ]","category":"page"},{"location":"docstrings.html#SimpleArgParse.ANSICODES","page":"Docstrings","title":"SimpleArgParse.ANSICODES","text":"Key-value store mapping from colors to ANSI codes. An internal constant.\n\n\n\n\n\n","category":"constant"},{"location":"docstrings.html#Index","page":"Docstrings","title":"Index","text":"","category":"section"},{"location":"docstrings.html","page":"Docstrings","title":"Docstrings","text":"","category":"page"}]
}
