defmodule MacroTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "ok checks return ok status" do
    conn = conn(:get, "/_ping")
    conn = MyOkPing.call(conn, [])
    %{"status" => status} = Poison.decode!(conn.resp_body)
    assert conn.status == 200
    assert status == "ok"
  end

  test "failures return 500 and failures" do
    conn = conn(:get, "/_ping")
    conn = MyFailurePing.call(conn, [])
    %{"status" => status, "failures" => fails} = Poison.decode!(conn.resp_body)
    assert conn.status == 500
    assert status == "failures"
    assert fails == ["always_fail"]
  end

  test "timeouts return 500 and failures" do
    conn = conn(:get, "/_ping")
    conn = MyTimeoutPing.call(conn, timeout: 400)
    %{"status" => status, "timeouts" => timeouts} = Poison.decode!(conn.resp_body)
    assert conn.status == 500
    assert status      == "failures"
    assert timeouts    == ["never_ever_happening"]
  end

  test "ok check returns ok" do
    assert MyMixedPing.run_check(:always_ok) == {:ok, :always_ok}
  end

  test "failure check returns fail" do
    assert MyMixedPing.run_check(:always_failure) == {:fail, :always_failure, "I always fail."}
  end

  test "errored check returns fail" do
    assert MyMixedPing.run_check(:always_error) == {:fail, :always_error, "Check failed."}
  end
end


