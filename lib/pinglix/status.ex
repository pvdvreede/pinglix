defmodule Pinglix.Status do
  alias Timex.Time

  defstruct status: "ok", now: nil, failures: [], timeouts: [], http_code: 200

  def build do
    %__MODULE__{}
  end

  def set_failed(status, check) do
    %__MODULE__{status | status: "failures", failures: status.failures ++ [check], http_code: 500}
  end

  def set_timed_out(status, check) do
    %__MODULE__{status | status: "failures", timeouts: status.timeouts ++ [check], http_code: 500}
  end

  def set_current_time(status) do
    %__MODULE__{status | now: Time.epoch(:secs)}
  end

  def to_struct(status) do
    status
    |> Map.delete(:__struct__)
    |> Map.delete(:http_code)
    |> remove_failures
    |> remove_timeouts
  end

  defp remove_failures(status = %{failures: []}) do
    status
    |> Map.delete(:failures)
  end

  defp remove_failures(status) do
    status
  end

  defp remove_timeouts(status = %{timeouts: []}) do
    status
    |> Map.delete(:timeouts)
  end

  defp remove_timeouts(status) do
    status
  end
end

defimpl Poison.Encoder, for: Pinglix.Status do
  def encode(status, opts) do
    Poison.Encoder.encode(Pinglix.Status.to_struct(status), opts)
  end
end
