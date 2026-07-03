defmodule BeamAtlas.Tools.CallGraph do
  @moduledoc "MCP tool: function/module/application call graph via :xref."
  use ExMCP.Tool

  alias BeamAtlas.Tools.Reply
  alias BeamAtlas.{Target, Envelope}
  alias BeamAtlas.Analyzer.Calls

  @queries ~w(E LC XC UC ME AE)

  @impl true
  def spec do
    %{
      "name" => "elixir_call_graph",
      "description" =>
        "Function/module/application call graph of an Elixir project via :xref (query E/LC/XC/UC/ME/AE).",
      "inputSchema" => %{
        "type" => "object",
        "required" => ["project_path", "query"],
        "properties" => %{
          "project_path" => %{"type" => "string"},
          "query" => %{"type" => "string", "enum" => @queries},
          "include_deps" => %{"type" => "boolean", "default" => false}
        }
      }
    }
  end

  @impl true
  def call(%{"project_path" => path, "query" => query} = args) when query in @queries do
    opts = [include_deps: Map.get(args, "include_deps", false)]

    payload =
      with {:ok, target} <- Target.resolve(path, opts),
           {:ok, edges} <- Calls.edges(target, String.to_atom(query)) do
        Envelope.edges(edges, "call_graph")
      else
        {:error, reason} -> Envelope.error(reason)
      end

    Reply.text(payload)
  end

  def call(args), do: Reply.text(Envelope.error({:bad_request, args}))
end
