defmodule Pinglix.Aggregator do
  alias Pinglix.Status

  def new do
    Status.build
  end

  def add_check({:fail, check, _}, accum) do
    Status.set_failed(accum, check)
  end

  def add_check(check, accum) do
    accum
  end
end
