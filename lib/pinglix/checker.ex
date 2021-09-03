defmodule Pinglix.Checker do
  alias Pinglix.Aggregator

  def run(module, checks, timeout) do
    checks
    |> Enum.map(&Task.async(module, :run_check, [&1]))
    |> run_checks(Aggregator.new(checks), timeout)
  end

  defp run_checks(tasks, aggregator, timeout) do
    timer_ref = make_ref()
    timer = Process.send_after(self(), {:timeout, timer_ref}, timeout)

    try do
      collect_results(tasks, aggregator, timer_ref)
    after
      :erlang.cancel_timer(timer)

      receive do
        {:timeout, ^timer_ref} -> :ok
      after
        0 -> :ok
      end
    end
  end

  defp collect_results([], aggregator, _), do: aggregator

  defp collect_results(tasks, aggregator, timer_ref) do
    receive do
      {:timeout, ^timer_ref} ->
        collect_results([], Aggregator.set_timeouts(aggregator), timer_ref)

      msg ->
        case find_task(tasks, msg) do
          {result, task} ->
            collect_results(
              List.delete(tasks, task),
              Aggregator.add_check(result, aggregator),
              timer_ref
            )

          nil ->
            collect_results(tasks, aggregator, timer_ref)
        end
    end
  end

  defp find_task(tasks, {ref, reply}) when is_reference(ref) do
    Enum.find_value(tasks, fn
      %Task{ref: ^ref} = task ->
        Process.demonitor(ref, [:flush])
        {reply, task}

      %Task{} ->
        nil
    end)
  end
end
