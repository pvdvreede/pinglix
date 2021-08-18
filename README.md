# Pinglix

[![Build Status](https://travis-ci.org/pvdvreede/pinglix.svg)](https://travis-ci.org/pvdvreede/pinglix)
[![Module Version](https://img.shields.io/hexpm/v/pinglix.svg)](https://hex.pm/packages/pinglix)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/pinglix/)
[![Total Download](https://img.shields.io/hexpm/dt/pinglix.svg)](https://hex.pm/packages/pinglix)
[![License](https://img.shields.io/hexpm/l/pinglix.svg)](https://github.com/pvdvreede/pinglix/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/pvdvreede/pinglix.svg)](https://github.com/pvdvreede/pinglix/commits/master)

Plug compatible health check system in Elixir based on https://github.com/jbarnette/pinglish.

See [.travis.yml](.travis.yml) for the supported versions of Elixir/Erlang.

## Setup

Pinglix is an Elixir [Hex package](https://hex.pm/packages/pinglix), so you can just add the following to your `mix.exs` file under `deps`:

```elixir
{:pinglix, "~> 1.1"}
```

## Usage

At its simplest form, create a module that `use`es `Pinglix` which will generate a Plug compatible middleware, put this module in your app to get the `/_ping` endpoint which follows numbers 1, 4, 6, 8, 9 of the [Pinglish](https://github.com/jbarnette/pinglish#the-spec) specification.

```elixir
defmodule MyApp.Ping do
  use Pinglix
end

defmodule MyApp do
  plug MyApp.Ping
end
```

In this form, the check always returns ok as all it is doing is confirming that your Plug compatible webserver is running. This might provide some benefit, but it is far more useful to be able to check backend/downstream services that your service relies on. For this use case you can use the following macro based setup to add custom checks for Pinglix to run whenever the `/_ping` endpoint is hit:

```elixir
defmodule MyApp.Ping do
  use Pinglix

  # return :ok if all is well, or :fail with a message
  # as the string
  defcheck :webservice do
    {:ok, %HTTPoison{status_code: code}} = HTTPoison.get("https://downstream.webservice/_ping")
    case code do
      200 -> :ok
      _   -> {:fail, "Received status #{code} from my webservice."}
    end
  end

  # any exceptions will set the check to fail and set the fail message to be the
  # exception message
  defcheck :db do
    DB.ping!
    :ok
  end

  # you can add some info to the json response even if the check passes
  # just return a tuple with :ok and a string instead of just the :ok atom
  defcheck :s3_info do
    count = S3.check_objects("bucket1")
    if count > 100 do
      {:fail, "S3 objects are at #{count}."}
    else
      {:ok, "S3 objects are at #{count}."}
    end
  end
end

defmodule MyApp do
  # you can provide a timeout option in milli seconds if you dont want
  # the default 29 seconds
  plug MyApp.Ping, timeout: 59_000 # this will timeout after 59 seconds

  # other plugs and endpoints.
end
```

There are some example ping Plugs at [test/test_helper.exs](test/test_helper.exs).

Using Pinglix will create a new plug with your checks builtin for you to include where you need. These checks will be run simultaneously. The request will return after 29 seconds as per the Pinglish specification, so all checks have 29 seconds each, rather than 29 seconds cumulatively.

## Copyright and License

Copyright (c) 2015 Paul Van de Vreede

This library licensed under the [MIT license](./LICENSE.md).
