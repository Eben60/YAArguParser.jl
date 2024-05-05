
## Changelog

### Release 2.0.0

- renamed functions
- removed hash
- ...

### Release 1.1.0

Switched the hashmap keys to a simple counter, resulting in faster execution. 

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

## License

MIT License

[Julia]: http://julialang.org

[docs-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url]: https://github.com/admercs/SimpleArgParse.jl

[codecov-img]: https://codecov.io/gh/admercs/SimpleArgParse.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/admercs/SimpleArgParse.jl

[CI-img]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml/badge.svg
[CI-url]: https://github.com/admercs/SimpleArgParse.jl/actions/workflows/github-actions.yml
