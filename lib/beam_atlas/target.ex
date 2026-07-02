defmodule BeamAtlas.Target do
  @moduledoc "Verifies, compiles, and locates the target project's compiled BEAM."

  def resolve(project_path, opts \\ []) do
    with :ok <- ensure_mix_project(project_path),
         :ok <- compile(project_path),
         {:ok, compile_path} <- ask_compile_path(project_path) do
      build_lib = Path.expand("../..", compile_path)
      all = build_lib |> Path.join("*/ebin") |> Path.wildcard()
      app = [compile_path]

      ebins = if Keyword.get(opts, :include_deps, false), do: all, else: app

      {:ok,
       %{
         path: project_path,
         app_ebins: Enum.map(ebins, &String.to_charlist/1),
         all_ebins: Enum.map(all, &String.to_charlist/1)
       }}
    end
  end

  defp ensure_mix_project(path) do
    if File.regular?(Path.join(path, "mix.exs")), do: :ok, else: {:error, :not_a_mix_project}
  end

  defp compile(path) do
    case System.cmd("mix", ["compile"], cd: path, stderr_to_stdout: true) do
      {_, 0} -> :ok
      {out, code} -> {:error, {:compile_failed, code, out}}
    end
  end

  defp ask_compile_path(path) do
    case System.cmd("mix", ["run", "--no-start", "-e", "IO.puts(Mix.Project.compile_path())"],
           cd: path,
           stderr_to_stdout: true
         ) do
      {out, 0} ->
        case out |> String.split("\n", trim: true) |> Enum.filter(&String.ends_with?(&1, "ebin")) |> List.last() do
          nil -> {:error, {:compile_path_not_found, out}}
          compile_path -> {:ok, compile_path}
        end

      {out, code} ->
        {:error, {:compile_path_failed, code, out}}
    end
  end
end
