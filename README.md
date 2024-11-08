# Advent Of Code

This is a small framework to help with [Advent of
Code](https://adventofcode.com/) by managing inputs, tests and boilerplate code
while you focus on problem solving in a TDD fashion.

- [Installation](#installation)
  - [Install the library](#install-the-library)
  - [Configuration](#configuration)
  - [Test configuration](#test-configuration)
  - [Install your cookie](#install-your-cookie)
- [Use the commands](#use-the-commands)
  - [mix aoc.open](#mix-aocopen)
  - [mix aoc.create](#mix-aoccreate)
  - [mix aoc.test](#mix-aoctest)
  - [mix aoc.run](#mix-aocrun)
  - [mix aoc.fetch](#mix-aocfetch)
  - [mix aoc.url](#mix-aocurl)
- [Custom default values for commands](#custom-default-values-for-commands)
- [Writing solutions](#writing-solutions)


## Installation


### Install the library

This framework is distributed as a library as it consists mostly of mix tasks.
You may add the dependency to your project, or add it to a new project created
with `mix new my_app`.

<!-- block:as_dep -->
```elixir
defp deps do
  [
    {:aoc, "~> 0.11"},
  ]
end
```
<!-- endblock:as_dep -->


### Configuration

If it does not exist, create a configuration file in your application:

```
mkdir -p config
touch config/config.exs
```

Then add the following configuration:

```elixir
import Config

# The prefix is used when creating solutions and test modules with
# `mix aoc.create`.
config :aoc, prefix: MyApp
```


### Test configuration

In order to run the `aoc.test` command described later in this document, you
need to declare that command as a test environment command.

In your`mix.exs` file, declare the following function:

```elixir
# mix.exs
def cli do
  [
    preferred_envs: ["aoc.test": :test]
  ]
end
```


### Install your cookie

Retrieve your cookie from the AoC website (with you browser developer tools) and write the session
ID in `$HOME/.adventofcode.session`. It should be a long hex number like
`53616c7415146f5f1d5792d97e3370392425dea84ca4653bd9a083f164ecd92278bef5b6bd50...`


## Use the commands

The following commands will use default `year` and `day` based on the current
date.

It is possible to override the defaults with the `mix aoc.set` command, or
provide the `--year` and `--day` options to any of them.

The following docs are generated from the tasks modules documentation. You can
get any of them using `mix help <command>`, for instance `mix help aoc.create`.

You may also get a quick summary of options by calling those commands with the
`--help` flag, as in `mix aoc.create --help`.

---

### mix aoc.open

<!-- block:mix.aoc.open -->
Opens the puzzle page with your defined browser on on adventofcode.com.

The command to call with the URL will be defined in the following order:

* Using the `AOC_BROWSER` environment variable.
* Using the `BROWSER` environment variable.
* Fallback to `xdg-open`.

#### Usage

```shell
mix aoc.open [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.open -->

---

### mix aoc.create

<!-- block:mix.aoc.create -->
This task will execute the following operations:

* Download the input from Advent of Code website into the `priv/inputs`
  directory.
* Create the solution module.
* Create a test module.

Existing files will not be overwritten. It is safe to call the command again
if you need to regenerate a deleted file.

The generated files will contain some comment blocks to help you get
accustomed to using this library. This can be annoying after some time. You
may disable generating those comments by setting `mix aoc.set -C` or passing
that `-C` flag when calling `mix aoc.create`.

#### Usage

```shell
mix aoc.create [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `-C, --skip-comments` - Do not include help comments in the generated code. Default value can be defined using `mix aoc.set`, otherwise comments are included.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.create -->

---

### mix aoc.test

<!-- block:mix.aoc.test -->
Runs your test file for the Advent of Code puzzle.

Note that test files generated by the `mix aoc.create` command are regular
ExUnit tests.

You can always run `mix test` or a test specified by a file and an optional
line number like this:

```shell
mix test test/2023/day01_test.exs:123
```

In order to use this command, you should define it as a test environment
command in your `mix.exs` file by defining a `cli/0` function:

```elixir
def cli do
  [
    preferred_envs: ["aoc.test": :test]
  ]
end
```

#### Usage

```shell
mix aoc.test [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `--trace` - forward option to `mix test`.
* `--stale` - forward option to `mix test`.
* `--failed` - forward option to `mix test`.
* `--seed <integer>` - forward option to `mix test`.
* `--max-failures <integer>` - forward option to `mix test`.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.test -->

---

### mix aoc.run

<!-- block:mix.aoc.run -->
Runs your solution with the corresponding year/day input from `priv/inputs`.

#### Usage

```shell
mix aoc.run [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `-p, --part <integer>` - Part of the puzzle. Defaults to both parts.
* `-b, --benchmark` - Runs the solution repeatedly for 5 seconds to print statistics about execution time. Defaults to `false`.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.run -->

---

### mix aoc.fetch

<!-- block:mix.aoc.fetch -->
This task will fetch the puzzle into `priv/inputs`.

It will not overwrite an existing input file.

#### Usage

```shell
mix aoc.fetch [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.fetch -->

---

### mix aoc.url

<!-- block:mix.aoc.url -->
Outputs the on adventofcode.com URL for a puzzle.

Useful to use in custom shell commands.

Note that due to Elixir compilation outputs you may need to grep for the URL.
For instance:

```shell
xdg-open $(mix aoc.url | grep 'https')
```

#### Usage

```shell
mix aoc.url [options]
```

#### Options

* `-y, --year <integer>` - Year of the puzzle. Defaults to today's year or custom default.
* `-d, --day <integer>` - Day of the puzzle. Defaults to today's day or custom default.
* `--help` - Displays this help.


<!-- endblock:mix.aoc.url -->

---


## Custom default values for commands

The `mix aoc.set` command allows to set the default year and day. Those values
are used by default when other commands are not called with `--year` or `--day`
options.

This is useful when working on a problem from a previous year, or when you
finish the last days after December 25th, so your CLI history or bash scripts
can just call `mix aoc.test` or `mix aoc.run` without options.

* `mix aoc.set --year 2022` – Set the default year to 2022.
* `mix aoc.set --day 12` – Set the default day.
* `mix aoc.set --year 2022 --day 12` – Set both defaults.
* `mix aoc.set -C` – Do not include comments in code generated by `mix
  aoc.create`.
* `mix aoc.set --reset --day 12` – Set the default day and delete other default values.
* `mix aoc.set --reset` – Delete every default values.


## Writing solutions

The `mix aoc.create` command will generate modules with the boilerplate code to
be called by `mix aoc.run` and the generated tests.

(Note: You can generate modules without the help comments by passing the `-C` flag in `mix aoc.create`.)

```elixir
defmodule MyApp.Y24.Day01 do
  alias AoC.Input

  def parse(input, _part) do
    # This function will receive the input path or an %AoC.Input.TestInput{}
    # struct.  To support the test you may read both types of input with either:
    #
    # * Input.stream!(input), equivalent to File.stream!/1
    # * Input.stream!(input, trim: true), equivalent to File.stream!/2
    # * Input.read!(input), equivalent to File.read!/1
    #
    # The role of your parse/2 function is to return a "problem" for the solve/2
    # function.
    #
    # For instance:
    #
    # input
    # |> Input.stream!()
    # |> Enum.map!(&my_parse_line_function/1)

    Input.read!(input)
  end

  def part_one(problem) do
    # This function receives the problem returned by parse/2 and must return
    # today's problem solution for part one.
    problem
  end

  # def part_two(problem) do
  #   problem
  # end
end
```

You may then use `mix aoc.test` to test your implementation against the examples in the puzzle description.

Finally, once your tests seem to be correct, you can use `mix aoc.run` to run
your solution with the actual input.

To call your code manually, you may use the following code:

```elixir
solution_for_p1 =
  "path/to/input/file"
  |> MyApp.Y23.Day1.parse(:part_one)
  |> MyApp.Y23.Day1.part_one()
```
