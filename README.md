Xapigee
=======

Xapigee is a little utility to help bootstrap an
[Apigee](http://apigee.com/about/) proxy API.

## What does it do?

Not much.

```sh
$ mix xapigee.generate from "/path/to/test_proxy.yml"
```

The above `mix` task takes a proxy description in YAML format (so far with a
fairly limited vocabulary) and emits the equivalent XML.

## Plans

- A "sensible-defaults" generator, in the style of `rails scaffold`, with
directories for the needed policies, jsc's, etc.

## How to contribute?

Instructions for installing Elixir on your platform can be found on
[Elixir's website](http://elixir-lang.org/). All you need is the Erlang VM and
Elixir.

After that, `$ git clone`, `$ cd $PROJECT`, and `$ mix deps.get` should have you
ready to rumble.

## Why Elixir?

Why not? I figured tail recursion and pattern matching would be an elegant way
to model YAML traversal and XML templating and Elixir has performed beautifully.
