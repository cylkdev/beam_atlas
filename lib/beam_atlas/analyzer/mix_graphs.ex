defmodule BeamAtlas.Analyzer.MixGraphs do
  @moduledoc "Mix-native DOT graphs, produced by shelling `mix` in the target."

  @xref_labels %{
    compile: "compile",
    export: "export",
    runtime: "runtime",
    compile_connected: "compile-connected"
  }

  def dot(target, :source_files), do: xref_dot(target, [])

  def dot(target, kind) when is_map_key(@xref_labels, kind) do
    xref_dot(target, ["--label", @xref_labels[kind]] ++ direct(kind))
  end

  def dot(target, :dependencies), do: tree_dot(target, "deps.tree", "deps_tree.dot", [])
  def dot(target, :applications), do: tree_dot(target, "app.tree", "app_tree.dot", [])
  def dot(_target, other), do: {:error, {:unknown_kind, other}}

  defp direct(kind) when kind in [:compile, :export, :runtime], do: ["--only-direct"]
  defp direct(_), do: []

  # `mix xref graph --format dot` does NOT print DOT to stdout; it writes
  # "xref_graph.dot" to the current directory (verified against Mix 1.18.4)
  # and prints a human-readable confirmation message to stdout instead.
  # We must read the file it writes, then clean it up.
  defp xref_dot(target, args) do
    case System.cmd("mix", ["xref", "graph", "--format", "dot"] ++ args, cd: target.path) do
      {_, 0} ->
        full = Path.join(target.path, "xref_graph.dot")
        result = File.read(full)
        File.rm(full)

        case result do
          {:ok, dot} -> {:ok, dot}
          {:error, reason} -> {:error, {:read_failed, reason}}
        end

      {out, code} ->
        {:error, {:mix_xref_failed, code, out}}
    end
  end

  # deps.tree/app.tree write <name>.dot; capture then clean up.
  defp tree_dot(target, task, file, args) do
    case System.cmd("mix", [task, "--format", "dot"] ++ args, cd: target.path) do
      {_, 0} ->
        full = Path.join(target.path, file)
        result = File.read(full)
        File.rm(full)

        case result do
          {:ok, dot} -> {:ok, dot}
          {:error, reason} -> {:error, {:read_failed, reason}}
        end

      {out, code} ->
        {:error, {:mix_tree_failed, code, out}}
    end
  end
end
