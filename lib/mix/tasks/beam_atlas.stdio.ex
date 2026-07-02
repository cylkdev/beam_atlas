defmodule Mix.Tasks.BeamAtlas.Stdio do
  @moduledoc "Run beam_atlas as a stdio MCP server."
  use Mix.Task
  @shortdoc "Start the beam_atlas stdio MCP server"

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    {:ok, _pid} = BeamAtlas.Server.start_link(transport: :stdio)

    Process.sleep(:infinity)
  end
end
