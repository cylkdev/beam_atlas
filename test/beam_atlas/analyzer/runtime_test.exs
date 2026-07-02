defmodule BeamAtlas.Analyzer.RuntimeTest do
  use ExUnit.Case
  alias BeamAtlas.Analyzer.Runtime

  test "supervision edges use child ids and recurse into sub-supervisors" do
    p_worker = spawn(fn -> :ok end)
    p_sub = spawn(fn -> :ok end)
    p_leaf = spawn(fn -> :ok end)

    which = fn
      :root -> [{Worker, p_worker, :worker, [Worker]}, {Sub, p_sub, :supervisor, [Sub]}]
      ^p_sub -> [{Leaf, p_leaf, :worker, [Leaf]}]
      _ -> []
    end

    edges = Runtime.supervision([:root], which)
    assert {"root", "Elixir.Worker"} in edges
    assert {"root", "Elixir.Sub"} in edges
    assert {"Elixir.Sub", "Elixir.Leaf"} in edges
  end

  test "tree_pids recurses into sub-supervisors to collect deep descendant pids" do
    p_worker = spawn(fn -> :ok end)
    p_sub = spawn(fn -> :ok end)
    p_leaf = spawn(fn -> :ok end)

    which = fn
      :root -> [{Worker, p_worker, :worker, [Worker]}, {Sub, p_sub, :supervisor, [Sub]}]
      ^p_sub -> [{Leaf, p_leaf, :worker, [Leaf]}]
      _ -> []
    end

    pids = Runtime.tree_pids([:root], which)
    assert p_worker in pids
    assert p_sub in pids
    assert p_leaf in pids
  end

  test "monitor edges are directional" do
    a = spawn(fn -> :ok end)
    info = fn ^a, :monitors -> {:monitors, [{:process, :some_name}]} end
    assert [{_, "some_name"}] = Runtime.monitors([a], info)
  end
end
