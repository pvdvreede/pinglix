defmodule MyMixedPing do
  use Pinglix

  defcheck :always_ok do
    :ok
  end

  defcheck :always_failure do
    {:fail, "I always fail."}
  end

  defcheck :always_error do
    raise "Check failed."
    :ok
  end
end

defmodule MyTimeoutPing do
  use Pinglix

  defcheck :never_gonna_happen do
    :timer.sleep 3
    :ok
  end
end

defmodule MyFailurePing do
  use Pinglix

  defcheck :always_fail do
    {:fail, "I will always fail."}
  end
end

defmodule MyOkPing do
  use Pinglix

  defcheck :always_ok do
    :ok
  end
end

ExUnit.start()
