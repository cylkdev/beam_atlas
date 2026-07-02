defmodule GraphFixture.MemoryStorage do
  @moduledoc false
  @behaviour GraphFixture.Storage
  @impl true
  def put(k, v), do: (Process.put(k, v) && :ok) || :ok
  @impl true
  def get(k), do: Process.get(k)
end
