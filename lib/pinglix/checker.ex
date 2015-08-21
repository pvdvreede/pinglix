defmodule Pinglix.Checker do
  alias Pinglix.Aggregator

  def run(module, checks, timeout \\ 29000) do
    checks
    |> Enum.map(&Task.async(module, :run_check, [&1]))
    |> collect_results(Aggregator.new)
  end

  defp collect_results([], aggregator), do: aggregator
  defp collect_results(tasks, aggregator) do
    receive do
      msg ->
        case Task.find(tasks, msg) do
          {result, task} ->
            collect_results(List.delete(tasks, task), Aggregator.add_check(result, aggregator))
          nil ->
            collect_results(tasks, aggregator)
        end
    end
  end
end
