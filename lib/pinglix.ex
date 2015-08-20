defmodule Pinglix do
  import Plug.Conn
  alias Timex.Time, as: Time

  def init(opts) do
    opts
  end

  def call(conn = %Plug.Conn{path_info: ["_ping"], method: "GET"}, _opts) do
    conn
    |> put_resp_content_type("application/json", "UTF-8")
    |> send_resp(200, response)
  end

  def call(conn, _opts) do
    conn
  end

  defp response do
    Poison.encode!(%{status: "ok", now: current_time}, pretty: true)
  end

  defp current_time do
    to_string(Time.epoch(:secs))
  end
end
