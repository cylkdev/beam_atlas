defmodule BeamAtlas.Tools.MixGraph do
  @moduledoc "MCP tool: Mix-native dependency graphs."
  use ExMCP.Tool

  import BeamAtlas.Tools.Reply
  alias BeamAtlas.{Target, Envelope}
  alias BeamAtlas.Analyzer.MixGraphs

  @kinds ~w(source_files compile export runtime compile_connected dependencies applications)

  @impl true
  def spec do
    %{
      "name" => "elixir_mix_graph",
      "description" =>
        "Mix-native dependency graphs (source-file, compile/export/runtime, deps, apps).",
      "inputSchema" => %{
        "type" => "object",
        "required" => ["project_path", "kind"],
        "properties" => %{
          "project_path" => %{"type" => "string"},
          "kind" => %{"type" => "string", "enum" => @kinds}
        }
      }
    }
  end

  @impl true
  def call(%{"project_path" => path, "kind" => kind}) when kind in @kinds do
    payload =
      with {:ok, target} <- Target.resolve(path),
           {:ok, dot} <- MixGraphs.dot(target, String.to_atom(kind)) do
        Envelope.dot(dot)
      else
        {:error, reason} -> Envelope.error(reason)
      end

    text(payload)
  end

  def call(args), do: text(Envelope.error({:bad_request, args}))
end
