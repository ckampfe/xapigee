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

## Why Elixir?

Why not? I figured tail recursion and pattern would be an elegant way to model
YAML traversal and XML templating and I wasn't disappointed.
