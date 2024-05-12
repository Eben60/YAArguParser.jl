
## Changelog

### Release 2.0.0

#### Breaking changes

- Renamed exported mutating functions, e.g. `add_example => add_example!`.
- Limited the number of exported functions.
- Hashmap keys no more used, therefore `get_key` function removed.
- Removed `has_key` function - use `haskey` instead.
- Removed `required` field of ArgumentParser: If a default value provided, then argument is obviously optional, otherwise considered required.
- Anything forgotten? - Please open an issue 🙂  

#### New features

- Support for (extensible) validators [(example)](@ref "Example 3 - validating arguments").
- Support for positional arguments [(example)](@ref "Example 4 - positional arguments, custom validator").
- Support for use from console apps [(example)](@ref "Example 4 - positional arguments, custom validator").
- The added function [`args_pairs`](@ref SimpleArgParse.args_pairs) returns pairs `argname => argvalue` for all arguments at once.
- Anything else?...


#### Other changes

- Precompile package using `PrecompileTools.jl` to improve startup time.
- General code refactoring.
- Made use of `public` keyword introduced in the coming `Julia v1.11`.
- Test suite extended and now includes `Aqua.jl` testing, too.
- Extensive `Documenter.jl`-based documentation you are reading now.
- Examples added.

### Release 1.1.0

- Switched the hashmap keys to a simple counter, resulting in faster execution. 

### Release 1.0.0

- Changed hashmap key from 8-bit to 16-bit to reduce collision likelihood.
- Added a usage/help message generator method.
- Added the `add_example`, `generate_usage`, `help`, `haskey`, and `getkey` methods.
- Added a single dependency, `OrderedCollections::OrderedDict`, to ensure correctness of argument parsing order.
- Squashed bugs in argument type parsing and conversion.
- Added test cases.
- Added examples.

### Release 0.1.0

- Initial launch :rocket:

## Related packages

- The popular [ArgParse](https://github.com/carlobaldassi/ArgParse.jl) offers much of the same functionality and more.
- The package [GivEmExel](https://github.com/Eben60/GivEmExel.jl) relies heavily onto `SimpleArgParse` and has been the stimulus for the development of `SimpleArgParse v2`

## License

MIT License

[Julia]: http://julialang.org

[docs-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url]: https://github.com/admercs/SimpleArgParse.jl

[codecov-img]: https://codecov.io/gh/admercs/SimpleArgParse.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/admercs/SimpleArgParse.jl

[CI-img]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml/badge.svg
[CI-url]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml
