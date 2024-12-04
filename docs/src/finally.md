
## New Features and Changelog

### Release 1.1.1

04.12.2024

#### Fixes

- Now correctly accepts negative values for numerical arguments.

### Release 1.1.0

28.07.2024

#### New features

- Function [`colorprint`](@ref YAArguParser.colorprint) now supports keywords `bold`, `italic`, 
    `underline` and `blink`, and accepts both `String` and `Symbol` as its `color` arg.


### Release 1.0.0 - changes as compared to [`SimpleArgParse`](https://github.com/admercs/SimpleArgParse.jl)

13.07.2024

#### Breaking changes

- Renamed exported/public mutating functions, e.g. `add_example => add_example!`.
- Mutating functions do not return `ArgumentParser` anymore: They return either `nothing`, or an `Exception`.
- Limited the number of exported functions.
- Hashmap keys no more used, therefore `get_key` function removed.
- Removed `has_key` function - use `haskey` instead.
- Removed `required` field of `ArgumentParser`: If a default value provided, then argument is obviously optional, otherwise considered required.
- Removed `authors`, `documentation`, `repository`, and `license` fields of `ArgumentParser`: 
    Should you need them, see [`Example 4`](@ref "Example 4 - custom parser, initparser") and the file `legacy_parser.jl`.
- Minimal `Julia` version set to `v1.9`.
- Anything forgotten?..

#### New features

- Support for (extensible) validators [(example)](@ref "Example 3 - validating arguments").
- Support for extensible parsers [(example)](@ref "Example 4 - custom parser, initparser").
- Support for positional arguments [(example)](@ref "Example 5 - positional arguments, custom validator, initparser").
- Support for use from console apps [(example)](@ref "Example 5 - positional arguments, custom validator, initparser").
- The added function [`initparser`](@ref YAArguParser.initparser) simplifies initilalization of nested structs.
- The added function [`args_pairs`](@ref YAArguParser.args_pairs) makes it possible get all arguments at once as pairs `[argname => argvalue]`.
- Depending on value of `throw_on_exception` field, functions processing the input would either throw on erroneous input, or return an `Exception` object for a less disruptive processing downstream.
- Anything forgotten?..

#### Other changes

- Precompile package using `PrecompileTools.jl` to improve startup time.
- General code refactoring.
- Made use of `public` keyword introduced in the coming `Julia v1.11`.
- Test suite extended and now includes `Aqua.jl` testing, too.
- Extensive `Documenter.jl`-based documentation you are reading now.
- Examples added.

## Related packages

- As already mentioned, this package is a fork of [`SimpleArgParse`](https://github.com/admercs/SimpleArgParse.jl).
- The popular [ArgParse](https://github.com/carlobaldassi/ArgParse.jl) offers much of the same functionality and more.
- [`Comonicon`](https://comonicon.org/), a CLI (Command Line Interface) generator.
- [`Fire`](https://github.com/ylxdzsw/Fire.jl) is a library for creating simple CLI from julia function definitions.
- [`mce`](https://github.com/diversable/maurice) (Maurice) CLI - The Julia Language project manager,
    with useful functionality for beginners and advanced programmers ... currently in the 'Alpha' phase.
- The package [GivEmExel](https://github.com/Eben60/GivEmExel.jl) relies heavily onto `YAArguParser` and has been the stimulus for it's development.

## Likes & dislikes?

Star on GitHub, open an issue, contact me on Julia Discourse.

## Copyright and License

© 2024 Eben60

Portions of this software are based in part on the work by Adam Erickson 

© 2024 Adam Erickson 

MIT License (see separate file `LICENSE`)
