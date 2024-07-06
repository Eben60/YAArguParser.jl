## Types

```@autodocs
Modules = [YAArgParser]
Order   = [:type, ]
```

## Functions

### Exported functions
```@docs
add_argument!
add_example!
args_pairs
colorprint
haskey
help
parse_args!
```

### Public functions
```@docs
YAArgParser.generate_usage!
YAArgParser.get_value
YAArgParser.getcolor
YAArgParser.parse_arg
YAArgParser.set_value!
YAArgParser.shell_split
YAArgParser.validate
```

### Internal functions

```@autodocs
Modules = [YAArgParser]
Order   = [:function]
Filter = t -> !any(occursin.(["add_argument!",
    "add_example!",
    "args_pairs",
    "colorprint",
    "haskey",
    "help",
    "parse_args!",
    "shell_split",
    "validate",
    "generate_usage!",
    "get_value",
    "getcolor",
    "parse_arg",
    "set_value!",], Ref(string(nameof(t)))))
```

## Constants

```@autodocs
Modules = [YAArgParser]
Order   = [:constant, ]
```

## Index

```@index
```