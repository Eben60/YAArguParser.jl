# Prefaces

## Preface to v.1

Started hackable, single-file, 320-line Julia package for command-line argument parsing, `SimpleArgParse` offering 95% of the functionality of  `ArgParse` using ~10% of the lines-of-code (LOC).

Does this need to be more complicated?

### Motivation

Parsing command-line arguments should not be complicated. Metaprogramming features such as macros and generators, while cool, are overkill. I wanted a simple command-line argument parsing library in the spirit of Python's [`argparse`](https://docs.python.org/3/library/argparse.html), but could not find one. The closest thing I found was [`ArgParse`](https://www.juliapackages.com/p/argparse), but I desired something even simpler. There's nothing worse than having to security audit a massive package for a simple task.

Here it is, a single, simple, 320-line file with one dependency (`OrderedCollections::OrderedDict`), a single nested data structure, and a few methods. Hack on it, build on it, and use it for your own projects. You can read all of the source code in around one minute.

Enjoy! 😎

## Preface to v.2

Now, at nearly 600 LOC, divided into several files, the package grew but is still much smaller than `ArgParse`. The code has been somewhat refactored, and features for interactive use in console applications and an extensible input validator has been added. See [Changelog](@ref) for details.