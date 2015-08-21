defmodule Pinglix do
  import Plug.Conn
  alias Pinglix.Status

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute __MODULE__, :checks, accumulate: true
      import Pinglix
      import Plug.Conn
      @before_compile Pinglix
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init(opts) do
        opts
      end

      def call(conn = %Plug.Conn{path_info: ["_ping"], method: "GET"}, _opts) do
        status = Pinglix.Checker.run(__MODULE__, @checks)
                 |> Pinglix.Status.set_current_time

        conn
        |> put_resp_content_type("application/json", "UTF-8")
        |> send_resp(status.http_code, Poison.encode!(status))
      end

      def call(conn, _opts), do: conn
    end
  end

  defmacro defcheck(name, do: block) do
    quote do
      @checks unquote(name)

      def run_check(unquote(name)) do
        try do
          result = unquote(block)
          case result do
            :ok        -> {:ok, unquote(name)}
            {:fail, m} -> {:fail, unquote(name), m}
            _          -> {:fail, unquote(name), "Pinglix check does not return the right clause"}
          end
        rescue
          e -> {:fail, unquote(name), Exception.message(e)}
        end
      end
    end
  end
end
