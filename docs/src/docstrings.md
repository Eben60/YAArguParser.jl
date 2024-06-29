## Types

```@autodocs
Modules = [SimpleArgParse2]
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
shell_split
validate
```

### Public functions
```@docs
SimpleArgParse2.generate_usage!
SimpleArgParse2.get_value
SimpleArgParse2.getcolor
SimpleArgParse2.parse_arg
SimpleArgParse2.set_value!
```

### Internal functions

```@autodocs
Modules = [SimpleArgParse2]
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
Modules = [SimpleArgParse2]
Order   = [:constant, ]
```

## Index

```@index
```