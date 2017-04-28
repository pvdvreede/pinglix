defmodule StatusTest do
  use ExUnit.Case, async: true
  import Pinglix.Status

  test "building status with all checks" do
    struct = build([:check1, :check2])
    assert struct.checks == [:check1, :check2]
    assert struct.http_code == 200
    assert struct.status == "ok"
    assert struct.timeouts == []
    assert struct.failures == []
    assert struct.passed == []
  end

  test "converting to struct" do
    struct = build() |> to_struct
    assert struct[:timeouts] == nil
    assert struct[:failures] == nil
    assert struct[:http_code] == nil
    assert struct[:checks] == nil
    assert struct[:passed] == nil
  end

  test "setting failures" do
    struct = build() |> set_failed(:test, "because...") |> set_failed(:test2, "it doesn't work")
    assert struct.failures == [:test, :test2]
    assert struct.status == "failures"
    assert struct.http_code == 503
    assert struct.test == "because..."
    assert struct.test2 == "it doesn't work"
  end

  test "setting passed" do
    struct = build() |> set_passed(:test) |> set_passed(:test2)
    assert struct.passed == [:test, :test2]
    assert struct.status == "ok"
    assert struct.http_code == 200
  end

  test "setting passed with message" do
    struct = build() |> set_passed(:test, "hi") |> set_passed(:test2, "hello")
    assert struct.passed == [:test, :test2]
    assert struct.status == "ok"
    assert struct.http_code == 200
    assert struct.test == "hi"
    assert struct.test2 == "hello"
  end

  test "setting timeouts" do
    struct = build() |> set_timed_out(:test) |> set_timed_out(:test2)
    assert struct.timeouts == [:test, :test2]
    assert struct.status == "failures"
    assert struct.http_code == 503
  end

  test "setting current time" do
    struct = build() |> set_current_time
    refute struct.now == nil
  end

  test "poison encoding for status" do
    json = build() |> set_timed_out(:test) |> Poison.encode!
    assert String.contains?(json, "\"status\":\"failures\"")
    assert String.contains?(json, "\"timeouts\":[\"test\"]")
    refute String.contains?(json, "\"failures\":")
    refute String.contains?(json, "\"http_code\":")
    refute String.contains?(json, "\"checks\":")
    refute String.contains?(json, "\"passed\":")
  end
end
