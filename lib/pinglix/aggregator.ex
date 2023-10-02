defmodule Pinglix.Aggregator do
  alias Pinglix.Status

  def new(checks) do
    Status.build(checks)
  end

  def add_check({:fail, check, msg}, status) do
    Status.set_failed(status, check, msg)
  end

  def add_check({:ok, check}, status) do
    Status.set_passed(status, check)
  end

  def add_check({:ok, check, msg}, status) do
    Status.set_passed(status, check, msg)
  end

  def set_timeouts(status) do
    (status.checks -- (status.failures ++ status.passed))
    |> Enum.reduce(status, &Status.set_timed_out(&2, &1))
  end
end
