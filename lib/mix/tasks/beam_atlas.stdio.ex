defmodule Mix.Tasks.BeamAtlas.Stdio do
  @moduledoc "Run beam_atlas as a stdio MCP server (cylkdev/ex_mcp)."
  use Mix.Task
  @shortdoc "Start the beam_atlas stdio MCP server"

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    ExMCP.Stdio.run(
      tools: [
        BeamAtlas.Tools.CallGraph,
        BeamAtlas.Tools.ImplementationGraph,
        BeamAtlas.Tools.MixGraph,
        BeamAtlas.Tools.RuntimeGraph
      ],
      server_info: %{"name" => "beam_atlas", "version" => "0.1.0"}
    )
  end
end
