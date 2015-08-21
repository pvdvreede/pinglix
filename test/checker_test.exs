defmodule CheckerTest do
  use ExUnit.Case, async: true
  import Pinglix.Checker

  test "run builds the failure state" do
    state = run(MyMixedPing, [:always_error, :always_failure], 1000)
    assert state == %Pinglix.Status{status: "failures", failures: [:always_error, :always_failure], http_code: 500}
  end

  test "run defaults to ok with no failures" do
    state = run(MyOkPing, [:always_ok], 1000)
    assert state == %Pinglix.Status{status: "ok", failures: [], http_code: 200}
  end
end
