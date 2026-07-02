defmodule BeamAtlas.Envelope do
  @moduledoc "Builds the JSON payload returned inside an MCP text content block."
  alias BeamAtlas.Dot

  def edges(edges, dot_name, dot_opts \\ []) do
    Jason.encode!(%{
      "edges" =>
        edges
        |> Enum.map(fn
          {f, t} -> [f, t]
          {f, t, l} -> [f, t, l]
        end)
        |> Enum.uniq()
        |> Enum.sort(),
      "dot" => Dot.build(dot_name, edges, dot_opts)
    })
  end

  def dot(dot), do: Jason.encode!(%{"edges" => nil, "dot" => dot})

  def error(reason), do: Jason.encode!(%{"error" => inspect(reason)})
end
