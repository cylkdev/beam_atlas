defmodule BeamAtlas.Analyzer.Runtime do
  @moduledoc "Live process graphs. Assembly is pure; inspectors are injected."

  def connect(node, cookie) do
    Node.set_cookie(node, cookie)

    case Node.connect(node) do
      true -> :ok
      _ -> {:error, {:connect_failed, node}}
    end
  end

  def supervision(roots, which_children_fun) do
    Enum.flat_map(roots, fn root ->
      walk(root, label(root), which_children_fun, [])
    end)
  end

  def tree_pids(roots, which_children_fun) do
    roots
    |> Enum.flat_map(fn root -> gather_pids(root, which_children_fun) end)
    |> Enum.uniq()
  end

  defp gather_pids(sup, which) do
    children =
      try do
        which.(sup)
      rescue
        _ -> []
      catch
        _, _ -> []
      end

    Enum.flat_map(children, fn {_id, pid, type, _mods} ->
      rest = if type == :supervisor and is_pid(pid), do: gather_pids(pid, which), else: []
      [pid | rest]
    end)
  end

  defp walk(sup, sup_label, which, acc) do
    children =
      try do
        which.(sup)
      rescue
        _ -> []
      catch
        _, _ -> []
      end

    Enum.reduce(children, acc, fn {id, pid, type, _mods}, acc ->
      clabel = child_label(id, pid)
      acc = [{sup_label, clabel} | acc]
      if type == :supervisor and is_pid(pid), do: walk(pid, clabel, which, acc), else: acc
    end)
  end

  def links(pids, info_fun) do
    for pid <- pids,
        {:links, links} <- [info_fun.(pid, :links)],
        linked <- links,
        is_pid(linked) do
      {label(pid), label(linked)}
    end
  end

  def monitors(pids, info_fun) do
    for pid <- pids,
        {:monitors, monitors} <- [info_fun.(pid, :monitors)],
        {:process, target} <- monitors do
      {label(pid), label(target)}
    end
  end

  defp child_label(id, pid) do
    cond do
      is_atom(id) and id not in [nil, :undefined] -> label(id)
      is_pid(pid) -> label(pid)
      true -> inspect(id)
    end
  end

  defp label(pid) when is_pid(pid), do: pid |> :erlang.pid_to_list() |> List.to_string()
  defp label(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp label(other), do: to_string(other)
end
