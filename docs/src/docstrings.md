## Types

```@autodocs
Modules = [YAArguParser]
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
YAArguParser.generate_usage!
YAArguParser.get_value
YAArguParser.getcolor
YAArguParser.parse_arg
YAArguParser.set_value!
YAArguParser.shell_split
YAArguParser.validate
```

### Internal functions

```@autodocs
Modules = [YAArguParser]
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
Modules = [YAArguParser]
Order   = [:constant, ]
```

## Index

```@index
```