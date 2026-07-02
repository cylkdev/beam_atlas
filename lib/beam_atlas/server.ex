defmodule BeamAtlas.Server do
  @moduledoc "MCP server exposing beam_atlas graph tools."
  use ExMCP.Server

  alias BeamAtlas.{Target, Envelope}
  alias BeamAtlas.Analyzer.{Calls, Implementations, MixGraphs, Runtime}

  deftool "elixir_call_graph" do
    meta do
      description("Function/module/application call graph via :xref (query E/LC/XC/UC/ME/AE).")
    end

    input_schema(%{
      type: "object",
      required: ["project_path", "query"],
      properties: %{
        project_path: %{type: "string"},
        query: %{type: "string", enum: ~w(E LC XC UC ME AE)},
        include_deps: %{type: "boolean", default: false}
      }
    })
  end

  deftool "elixir_implementation_graph" do
    meta do
      description("Behaviour and protocol implementation edges of an Elixir project.")
    end

    input_schema(%{
      type: "object",
      required: ["project_path", "kind"],
      properties: %{
        project_path: %{type: "string"},
        kind: %{type: "string", enum: ~w(behaviours protocols both)},
        include_deps: %{type: "boolean", default: false}
      }
    })
  end

  deftool "elixir_mix_graph" do
    meta do
      description("Mix-native dependency graphs (source-file, compile/export/runtime, deps, apps).")
    end

    input_schema(%{
      type: "object",
      required: ["project_path", "kind"],
      properties: %{
        project_path: %{type: "string"},
        kind: %{
          type: "string",
          enum: ~w(source_files compile export runtime compile_connected dependencies applications)
        }
      }
    })
  end

  deftool "elixir_runtime_graph" do
    meta do
      description("Live supervision, process-link, or monitor graph of a running node.")
    end

    input_schema(%{
      type: "object",
      required: ["node", "cookie", "kind"],
      properties: %{
        node: %{type: "string"},
        cookie: %{type: "string"},
        kind: %{type: "string", enum: ~w(supervision links monitors)},
        roots: %{type: "array", items: %{type: "string"}}
      }
    })
  end

  @call_queries ~w(E LC XC UC ME AE)
  @impl_kinds ~w(behaviours protocols both)
  @mix_kinds ~w(source_files compile export runtime compile_connected dependencies applications)
  @runtime_kinds ~w(supervision links monitors)

  @impl true
  def handle_tool_call("elixir_call_graph", %{"project_path" => path, "query" => query} = args, state) do
    if query not in @call_queries do
      {:ok, %{content: [text(Envelope.error({:invalid_argument, "query", query}))]}, state}
    else
      opts = [include_deps: Map.get(args, "include_deps", false)]

      payload =
        with {:ok, target} <- Target.resolve(path, opts),
             {:ok, edges} <- Calls.edges(target, String.to_atom(query)) do
          Envelope.edges(edges, "call_graph")
        else
          {:error, reason} -> Envelope.error(reason)
        end

      {:ok, %{content: [text(payload)]}, state}
    end
  end

  def handle_tool_call("elixir_implementation_graph", %{"project_path" => path, "kind" => kind} = args, state) do
    if kind not in @impl_kinds do
      {:ok, %{content: [text(Envelope.error({:invalid_argument, "kind", kind}))]}, state}
    else
      opts = [include_deps: Map.get(args, "include_deps", false)]

      payload =
        with {:ok, target} <- Target.resolve(path, opts),
             {:ok, edges} <- gather_impl(target, kind) do
          Envelope.edges(edges, "implementations")
        else
          {:error, reason} -> Envelope.error(reason)
        end

      {:ok, %{content: [text(payload)]}, state}
    end
  end

  def handle_tool_call("elixir_mix_graph", %{"project_path" => path, "kind" => kind}, state) do
    if kind not in @mix_kinds do
      {:ok, %{content: [text(Envelope.error({:invalid_argument, "kind", kind}))]}, state}
    else
      payload =
        with {:ok, target} <- Target.resolve(path),
             {:ok, dot} <- MixGraphs.dot(target, String.to_atom(kind)) do
          Envelope.dot(dot)
        else
          {:error, reason} -> Envelope.error(reason)
        end

      {:ok, %{content: [text(payload)]}, state}
    end
  end

  def handle_tool_call("elixir_runtime_graph", %{"node" => node, "cookie" => cookie, "kind" => kind} = args, state) do
    if kind not in @runtime_kinds do
      {:ok, %{content: [text(Envelope.error({:invalid_argument, "kind", kind}))]}, state}
    else
      node = String.to_atom(node)
      cookie = String.to_atom(cookie)
      roots = args |> Map.get("roots", []) |> Enum.map(&String.to_atom/1)

      payload =
        case Runtime.connect(node, cookie) do
          :ok -> Envelope.edges(runtime_edges(node, kind, roots), "runtime", direction: runtime_dir(kind))
          {:error, reason} -> Envelope.error(reason)
        end

      {:ok, %{content: [text(payload)]}, state}
    end
  end

  def handle_tool_call(_name, _args, state) do
    {:ok, %{content: [text(Envelope.error({:bad_request, "missing or unknown arguments"}))]}, state}
  end

  defp gather_impl(target, "behaviours"), do: Implementations.behaviours(target)
  defp gather_impl(target, "protocols"), do: Implementations.protocols(target)

  defp gather_impl(target, "both") do
    with {:ok, b} <- Implementations.behaviours(target),
         {:ok, p} <- Implementations.protocols(target),
         do: {:ok, b ++ p}
  end

  defp runtime_dir("links"), do: :undirected
  defp runtime_dir(_), do: :directed

  defp runtime_edges(node, "supervision", roots) do
    which = fn sup -> :rpc.call(node, Supervisor, :which_children, [sup]) end
    Runtime.supervision(roots, which)
  end

  defp runtime_edges(node, "links", roots) do
    info = fn pid, key -> :rpc.call(node, Process, :info, [pid, key]) end
    Runtime.links(runtime_pids(node, roots), info)
  end

  defp runtime_edges(node, "monitors", roots) do
    info = fn pid, key -> :rpc.call(node, Process, :info, [pid, key]) end
    Runtime.monitors(runtime_pids(node, roots), info)
  end

  defp runtime_pids(node, roots) do
    which = fn sup -> :rpc.call(node, Supervisor, :which_children, [sup]) end

    roots
    |> Runtime.tree_pids(which)
    |> Enum.filter(&is_pid/1)
    |> Enum.uniq()
  end
end
