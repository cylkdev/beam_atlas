defmodule GraphFixture do
  @moduledoc false
  def store(k, v), do: GraphFixture.MemoryStorage.put(k, v)
  def fetch(k), do: GraphFixture.MemoryStorage.get(k)
end
