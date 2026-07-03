defmodule Mix.Tasks.BeamAtlas.Stdio do
  @moduledoc "Run beam_atlas as a stdio MCP server (cylkdev/ex_mcp)."
  use Mix.Task
  @shortdoc "Start the beam_atlas stdio MCP server"

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")
    BeamAtlas.StdioServer.run()
  end
end
