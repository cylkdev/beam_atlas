defmodule BeamAtlas.Analyzer.Calls do
  @moduledoc "Function/module/application call graphs via Erlang :xref."

  @compile {:no_warn_undefined, :xref}

  @module_queries [:E, :LC, :XC, :UC, :ME]

  def edges(target, query) when query in @module_queries do
    with_server(:beam_atlas_calls, fn server ->
      Enum.each(target.app_ebins, fn ebin ->
        :xref.add_directory(server, ebin, verbose: false, warnings: false)
      end)

      run_query(server, query)
    end)
  end

  def edges(target, :AE) do
    with_server(:beam_atlas_calls_app, fn server ->
      target.app_ebins
      |> Enum.map(&Path.dirname(List.to_string(&1)))
      |> Enum.each(fn app_dir ->
        :xref.add_application(server, String.to_charlist(app_dir),
          verbose: false,
          warnings: false
        )
      end)

      run_query(server, :AE)
    end)
  end

  defp run_query(server, query) do
    case :xref.q(server, String.to_charlist(Atom.to_string(query))) do
      {:ok, calls} -> {:ok, Enum.map(calls, fn {c, e} -> {label(c), label(e)} end)}
      {:error, _kind, reason} -> {:error, reason}
    end
  end

  defp with_server(name, fun) do
    {:ok, _} = :xref.start(name)

    try do
      fun.(name)
    after
      :xref.stop(name)
    end
  end

  defp label({m, f, a}), do: "#{inspect(m)}.#{f}/#{a}"
  defp label(m) when is_atom(m), do: inspect(m)
  defp label(other), do: to_string(other)
end
