# Pinglix

Plug compatible health check system in Elixir based on https://github.com/jbarnette/pinglish.

## Usage

At its simplest form, create a module that `use`es `Pinglix` which will generate a Plug compatiable middleware, put this module in your app to get the `/_ping` endpoint which follows numbers 1, 4, 6, 8, 9 of the [Pingolish](https://github.com/jbarnette/pinglish#the-spec) specification.

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
  # any exceptions will set the check to fail and set the error
  # as the string
  defcheck :webservice do
    {:ok, %HTTPoison{status_code: code}} = HTTPoison.get("https://downstream.webservicei/_ping")
    case code do
      200 -> :ok
      _   -> {:fail, "Received status #{code} from my webservice."}
    end
  end

  defcheck :db do
    DB.ping!
    :ok
  end
end

defmodule MyApp do
  plug MyApp.Ping

  # other plugs and endpoints.
end
```

There are some example ping Plugs at [test/test_helper.exs](test/test_helper.exs).

Using Pinglix will create a new plug with your checks builtin for you to include where you need. These checks will be run simultaneously. The request will return after 29 seconds as per the Pinglish specification, so all checks have 29 seconds each, rather than 29 seconds cumulatively.
