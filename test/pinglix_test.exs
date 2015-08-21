defmodule MySimplePing do
  use Pinglix
end

defmodule PinglixTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts MySimplePing.init([])

  setup do
    conn = conn(:get, "/_ping")
    conn = MySimplePing.call(conn, @opts)
    {:ok, %{conn: conn}}
  end

  test "pinglix ignores all other paths" do
    conn = MySimplePing.call(conn(:get, "/somewhere"), @opts)
    assert conn.state == :unset
  end

  test "pinglix ignores all other methods" do
    conn = MySimplePing.call(conn(:post, "/_ping"), @opts)
    assert conn.state == :unset
  end

  test "application responds to GET /_ping", %{conn: conn} do
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "application uses correct content-type", %{conn: conn} do
    assert get_resp_header(conn, "content-type") == ["application/json; charset=UTF-8"]
  end

  test "application returns now and status keys", %{conn: conn} do
    %{"status" => status, "now" => _now} = Poison.decode!(conn.resp_body)
    assert status == "ok"
  end

  test "now key is not locked to one time", %{conn: conn} do
    :timer.sleep(1000)
    second_conn = conn(:get, "/_ping")
    second_conn = MySimplePing.call(second_conn, @opts)
    %{"now" => first_now} = Poison.decode!(conn.resp_body)
    %{"now" => second_now} = Poison.decode!(second_conn.resp_body)
    refute first_now == second_now
  end
end
