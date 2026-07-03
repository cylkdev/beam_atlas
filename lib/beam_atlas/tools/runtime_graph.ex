defmodule BeamAtlas.Tools.RuntimeGraph do
  @moduledoc "MCP tool: live supervision, process-link, or monitor graph of a running node."
  use ExMCP.Tool

  alias BeamAtlas.Tools.Reply
  alias BeamAtlas.Envelope
  alias BeamAtlas.Analyzer.Runtime

  @kinds ~w(supervision links monitors)

  @impl true
  def spec do
    %{
      "name" => "elixir_runtime_graph",
      "description" => "Live supervision, process-link, or monitor graph of a running node.",
      "inputSchema" => %{
        "type" => "object",
        "required" => ["node", "cookie", "kind"],
        "properties" => %{
          "node" => %{"type" => "string"},
          "cookie" => %{"type" => "string"},
          "kind" => %{"type" => "string", "enum" => @kinds},
          "roots" => %{"type" => "array", "items" => %{"type" => "string"}}
        }
      }
    }
  end

  @impl true
  def call(%{"node" => node, "cookie" => cookie, "kind" => kind} = args) when kind in @kinds do
    node = String.to_atom(node)
    cookie = String.to_atom(cookie)
    roots = args |> Map.get("roots", []) |> Enum.map(&String.to_atom/1)

    payload =
      case Runtime.connect(node, cookie) do
        :ok -> Envelope.edges(edges(node, kind, roots), "runtime", direction: dir(kind))
        {:error, reason} -> Envelope.error(reason)
      end

    Reply.text(payload)
  end

  def call(args), do: Reply.text(Envelope.error({:bad_request, args}))

  defp dir("links"), do: :undirected
  defp dir(_), do: :directed

  defp edges(node, "supervision", roots) do
    which = fn sup -> :rpc.call(node, Supervisor, :which_children, [sup]) end
    Runtime.supervision(roots, which)
  end

  defp edges(node, "links", roots) do
    info = fn pid, key -> :rpc.call(node, Process, :info, [pid, key]) end
    Runtime.links(pids(node, roots), info)
  end

  defp edges(node, "monitors", roots) do
    info = fn pid, key -> :rpc.call(node, Process, :info, [pid, key]) end
    Runtime.monitors(pids(node, roots), info)
  end

  defp pids(node, roots) do
    which = fn sup -> :rpc.call(node, Supervisor, :which_children, [sup]) end

    roots
    |> Runtime.tree_pids(which)
    |> Enum.filter(&is_pid/1)
    |> Enum.uniq()
  end
end
