defmodule CheckerTest do
  use ExUnit.Case, async: true
  import Pinglix.Checker

  test "run builds the failure state" do
    state = run(MyMixedPing, [:always_error, :always_failure], 1000)
    assert state.status == "failures"
    assert Enum.sort(state.failures) == [:always_error, :always_failure]
    assert state.http_code == 503
    assert state.always_error == "Check failed."
    assert state.always_failure == "I always fail."
  end

  test "run defaults to ok with no failures" do
    state = run(MyOkPing, [:always_ok], 1000)
    assert state.http_code == 200
    assert state.passed == [:always_ok]
    assert state.failures == []
    assert state.status == "ok"
  end

  test "run builds the timeout state for both" do
    state = run(MyTimeoutPing, [:never_gonna_happen, :never_ever_happening], 200)
    assert Enum.sort(state.timeouts) == [:never_ever_happening, :never_gonna_happen]
    assert state.passed == []
    assert state.status == "failures"
    assert state.http_code == 503
  end

  test "run builds the timeout state for the longer timeout" do
    state =
      run(MyTimeoutPing, [:never_gonna_happen, :never_ever_happening, :never_gonna_happen2], 400)

    assert state.timeouts == [:never_ever_happening]
    assert Enum.sort(state.passed) == [:never_gonna_happen, :never_gonna_happen2]
    assert state.status == "failures"
    assert state.http_code == 503
  end
end
