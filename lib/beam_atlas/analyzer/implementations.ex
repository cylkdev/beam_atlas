defmodule BeamAtlas.Analyzer.Implementations do
  @moduledoc "Interface-to-implementation graphs: behaviours and protocols."

  def behaviours(target) do
    edges =
      target.app_ebins
      |> Enum.flat_map(&beam_files/1)
      |> Enum.flat_map(fn beam ->
        {module, behaviours} = read_behaviours(beam)
        for b <- behaviours, do: {inspect(b), inspect(module)}
      end)

    {:ok, edges}
  end

  def protocols(target) do
    paths = target.app_ebins

    edges =
      paths
      |> Protocol.extract_protocols()
      |> Enum.flat_map(fn proto ->
        for impl <- Protocol.extract_impls(proto, paths), do: {inspect(proto), inspect(impl)}
      end)

    {:ok, edges}
  end

  defp beam_files(ebin), do: ebin |> List.to_string() |> Path.join("*.beam") |> Path.wildcard()

  defp read_behaviours(beam) do
    case :beam_lib.chunks(String.to_charlist(beam), [:attributes]) do
      {:ok, {module, [{:attributes, attrs}]}} ->
        {module, Keyword.get(attrs, :behaviour, []) ++ Keyword.get(attrs, :behavior, [])}

      _ ->
        {nil, []}
    end
  end
end
