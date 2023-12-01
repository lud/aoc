# Advent Of Code

This is a small framework to help with [Advent of
Code](https://adventofcode.com/) by managing inputs, tests and boilerplate code
while you focus on problem solving in a TDD fashion.

## Installation

### Install the library

This framework is distributed as a library as it consists mostly of mix tasks.
You may add the dependency to your project, or add it to a new project created
with `mix new my_app`.

```elixir
defp deps do
  [
    {:aoc, "~> 0.2"},
  ]
end
```

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


### Install your cookie

Retrieve your cookie from the AoC website (with you browser developer tools) and write the session
ID in `$HOME/.adventofcode.session`. It should be a long hex number like
`53616c7465645f5f1d5792d97e3370392425dea84ca4653bd9a083f164ecd92278bef5b6bd50...`


## Use the commands

The following commands use the default year and day based on current date. It is
possible to override the defaults with the `mix aoc.set` command.

* `mix aoc.create` – Create the solution file, the test file and the input file
  for the current day. The input is downloaded from the AoC website and requires
  the session cookie. But you can create any of those files manually and the
  command will not overwrite them.
* `mix aoc.fetch` – Download the input. This will not overwrite an existing
  file. Inputs are stored in the `priv` directory.
* `mix aoc.open` – Open the problem page on AoC website.
* `mix aoc.test` – Run the tests. This relies on the `mix test` command and will
  call it with the default test filename that would be generated byt `mix
  aoc.create`.
* `mix aoc.run` – Run the solution. This command also accepts a `--part` option
  to run only one part of the solution.


## Defaults management commands

The `mix aoc.set` command allows to set the default year and day. Those values
are used by default when other commands are not called with `--year` or `--day`
options.

This is useful when working on a problem from a previous year, or when you
finish the last days after December 25th, so your CLI history or bash scripts
can just call `mix aoc.test` or `mix aoc.run` without options.

* `mix aoc.set --year 2022` – Set the default year to 2022
* `mix aoc.set --day 12` – Set the default day
* `mix aoc.set --year 2022 --day 12` – Set both defaults
* `mix aoc.set` – Delete the default values


## Writing solutions

The `mix aoc.create` command will generate modules with the boilerplate code to
be called by `mix aoc.run` and the generated tests.

```elixir
defmodule AoC.Y23.Day1 do
  alias AoC.Input, warn: false

  def read_file(file, _part) do
    # Return each line
    Input.stream!(file, trim: true)
    # Or return the whole file
    # Input.read!(file)
  end

  def parse_input(input, _part) do
    input
  end

  def part_one(problem) do
    problem
  end

  def part_two(problem) do
    problem
  end
end
```

To call your code manually, you may use the following code:

```elixir
solution_for_p1 =
  "path/to/input/file"
  |> AoC.Y23.Day1.read_file(:part_one)
  |> AoC.Y23.Day1.parse_input(:part_one)
  |> AoC.Y23.Day1.part_one(:part_one)
```

The generated tests will also call those functions one by one, so you can debug
and assert each part separately.

The different callbacks are:

* `read_file/2` and `parse_input/2` – The first one accepts an input file path,
  or a `AoC.Input.FakeFile` struct from the tests. Call `Input.read!` or
  `Input.stream!` to return the whole contents or a stream of lines.

  The return value will be passed to `parse_input/2`. This allows to separate
  the parsing logic from the raw file manipulation. Most logic is generally
  contained in one of those two functions, and the other one is a oneliner.

  Note that the second argument to each callback, `:part_one` or `:part_two` can
  help to apply different logic for each problem part.

* `part_one/1` and `part_two/1` – The first argument is the result of
  `parse_input/2`. The return should be the solution to the problem that will be
  printed by `mix aoc.run`.

  The return value is also checked in the generated tests.

  Some problems may require to print a drawing to the console, or produce other
  side effects, so you may return a dummy value those callbacks.

