defmodule MacroTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "ok checks return ok status" do
    conn = conn(:get, "/_ping")
    conn = MyOkPing.call(conn, [])
    %{"status" => status, "ok_with_message" => msg} = Poison.decode!(conn.resp_body)
    assert conn.status == 200
    assert status == "ok"
    assert msg == "All is well"
  end

  test "failures return 503 and failures" do
    conn = conn(:get, "/_ping")
    conn = MyFailurePing.call(conn, [])
    %{"status" => status, "failures" => fails, "always_fail" => message} = Poison.decode!(conn.resp_body)
    assert conn.status == 503
    assert status == "failures"
    assert fails == ["always_fail"]
    assert message == "I will always fail."
  end

  test "timeouts return 503 and failures" do
    conn = conn(:get, "/_ping")
    conn = MyTimeoutPing.call(conn, timeout: 400)
    %{"status" => status, "timeouts" => timeouts} = Poison.decode!(conn.resp_body)
    assert conn.status == 503
    assert status      == "failures"
    assert timeouts    == ["never_ever_happening"]
  end


  test "ok check returns ok" do
    assert MyMixedPing.run_check(:always_ok) == {:ok, :always_ok}
  end

  test "ok check with message returns msg tuple" do
    assert MyOkPing.run_check(:ok_with_message) == {:ok, :ok_with_message, "All is well"}
  end

  test "failure check returns fail" do
    assert MyMixedPing.run_check(:always_failure) == {:fail, :always_failure, "I always fail."}
  end

  test "errored check returns fail" do
    assert MyMixedPing.run_check(:always_error) == {:fail, :always_error, "Check failed."}
  end
end


