defmodule BeamAtlas.Tools.ImplementationGraph do
  @moduledoc "MCP tool: behaviour and protocol implementation edges."
  use ExMCP.Tool

  alias BeamAtlas.Tools.Reply
  alias BeamAtlas.{Target, Envelope}
  alias BeamAtlas.Analyzer.Implementations

  @kinds ~w(behaviours protocols both)

  @impl true
  def spec do
    %{
      "name" => "elixir_implementation_graph",
      "description" => "Behaviour and protocol implementation edges of an Elixir project.",
      "inputSchema" => %{
        "type" => "object",
        "required" => ["project_path", "kind"],
        "properties" => %{
          "project_path" => %{"type" => "string"},
          "kind" => %{"type" => "string", "enum" => @kinds},
          "include_deps" => %{"type" => "boolean", "default" => false}
        }
      }
    }
  end

  @impl true
  def call(%{"project_path" => path, "kind" => kind} = args) when kind in @kinds do
    opts = [include_deps: Map.get(args, "include_deps", false)]

    payload =
      with {:ok, target} <- Target.resolve(path, opts),
           {:ok, edges} <- gather(target, kind) do
        Envelope.edges(edges, "implementations")
      else
        {:error, reason} -> Envelope.error(reason)
      end

    Reply.text(payload)
  end

  def call(args), do: Reply.text(Envelope.error({:bad_request, args}))

  defp gather(target, "behaviours"), do: Implementations.behaviours(target)
  defp gather(target, "protocols"), do: Implementations.protocols(target)

  defp gather(target, "both") do
    with {:ok, b} <- Implementations.behaviours(target),
         {:ok, p} <- Implementations.protocols(target),
         do: {:ok, b ++ p}
  end
end
