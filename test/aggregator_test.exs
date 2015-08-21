defmodule AggregatorTest do
  use ExUnit.Case, async: true
  alias Pinglix.Aggregator
  alias Pinglix.Status

  test "assigning all timeouts" do
    status = Aggregator.new([:check1, :check2, :check3])
             |> Status.set_failed(:check3, "Im failing!!")
             |> Status.set_passed(:check2)
             |> Aggregator.set_timeouts
    assert status.timeouts == [:check1]
  end
end
