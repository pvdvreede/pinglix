# Pinglix

Plug compatible health check system in Elixir based on https://github.com/jbarnette/pinglish.

## Usage

At its simplest form, put the Pinglix plug in your app to get the `/_ping` endpoint which follows numbers 1, 3, 4, 5, 6, 8, 9 of the [Pingolish](https://github.com/jbarnette/pinglish#the-spec) specification.

```elixir
defmodule MyApp do
  plug Pinglix
end
```
