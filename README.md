# ElixirIdenticon

A small Elixir application that creates Identicon PNG images for user-defined character sequences.

The application consists of a main pipeline that takes a string passed as argument and uses it for for Identicon generation.

Intended for use through Elixir's interactive shell.

Created as a learning experience through [The Complete Elixir and Phoenix Bootcamp](https://www.udemy.com/course/the-complete-elixir-and-phoenix-bootcamp-and-tutorial/) course by Stephen Grider.

## Installation

Please ensure you have both Elixir and Erlang installed and available on your machine. Should you use [asdf](https://github.com/asdf-vm/asdf) to manage versions in your system, a `.tool-versions` file is available in this project.

Afterwards, simply run the command below on your terminal at this project's root directory:


```
mix deps.get
```

## Usage

With dependencies installed, simply open the Elixir interactive shell:

```
iex -S mix
```

Then import this application's main module:

```elixir
iex> ElixirIdenticon
```

Generate Identicons by passing a desired string to `main` function:

```elixir
iex> ElixirIdenticon.main("example")
```

Generated images are written to the `/outputs/` directory.
