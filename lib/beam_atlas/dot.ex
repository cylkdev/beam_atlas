defmodule BeamAtlas.Dot do
  @moduledoc "Builds deterministic DOT source: sorted, de-duplicated, escaped."

  def build(name, edges, opts \\ []) do
    {header, connector} =
      case Keyword.get(opts, :direction, :directed) do
        :directed -> {"digraph", "->"}
        :undirected -> {"graph", "--"}
      end

    body =
      edges
      |> Enum.map(&normalize(&1, connector))
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map_join("\n", fn {from, to, label} ->
        label_part = if label in [nil, ""], do: "", else: ~s( [label="#{escape(label)}"])
        ~s(  "#{escape(from)}" #{connector} "#{escape(to)}"#{label_part};)
      end)

    "#{header} #{name} {\n  rankdir=LR;\n#{body}\n}\n"
  end

  def escape(value) do
    value
    |> to_string()
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
  end

  defp normalize({from, to}, connector), do: normalize({from, to, nil}, connector)

  defp normalize({from, to, label}, connector) do
    from = to_string(from)
    to = to_string(to)
    {from, to} = if connector == "--" and to < from, do: {to, from}, else: {from, to}
    {from, to, label}
  end
end
