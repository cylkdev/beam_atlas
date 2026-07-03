defmodule BeamAtlas.StdioServer do
  @moduledoc """
  Task process that serves beam_atlas as a stdio MCP server.

  Reads JSON-RPC from stdin until EOF, then shuts the VM down. Supervised
  by `BeamAtlas.Supervisor` when running as a release (e.g. a Burrito
  binary); in dev/test it is started explicitly via `mix beam_atlas.stdio`.
  """

  use Task

  @tools [
    BeamAtlas.Tools.CallGraph,
    BeamAtlas.Tools.ImplementationGraph,
    BeamAtlas.Tools.MixGraph,
    BeamAtlas.Tools.RuntimeGraph
  ]

  @server_info %{
    "name" => "#{Mix.Project.config()[:app]}",
    "version" => Mix.Project.config()[:version]
  }

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(opts \\ []) do
    ensure_stdout_reserved_for_mcp!()
    ExMCP.Stdio.run(tools: @tools, server_info: @server_info)
    if opts[:halt_on_eof], do: System.stop(0)
  end

  defp ensure_stdout_reserved_for_mcp! do
    if BeamAtlas.Config.logger_default_handler_config_type() !== :standard_error do
      raise """
      stdout must be reserved for the MCP stdio protocol.

      Add the following to config.exs:

      ```
      # Send application logs to stderr so stdout is used only for MCP messages.
      # This keeps logs out of protocol responses without changing return values.
      config :logger, :default_handler, config: [type: :standard_error]
      ```
      """
    end
  end
end
