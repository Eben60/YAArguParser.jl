# SimpleArgParse.jl Documentation

```@contents
```

## Types

```@autodocs
Modules = [SimpleArgParse]
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
SimpleArgParse.generate_usage!
SimpleArgParse.get_value
SimpleArgParse.getcolor
SimpleArgParse.parse_arg
SimpleArgParse.set_value!
```

### Internal functions

```@autodocs
Modules = [SimpleArgParse]
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
Modules = [SimpleArgParse]
Order   = [:constant, ]
```

## Index

```@index
```