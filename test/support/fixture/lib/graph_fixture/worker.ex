defmodule GraphFixture.Worker do
  @moduledoc false
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  @impl true
  def init(:ok), do: {:ok, %{}}
end
