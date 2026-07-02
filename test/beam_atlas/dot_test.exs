defmodule BeamAtlas.DotTest do
  use ExUnit.Case
  alias BeamAtlas.Dot

  test "directed graph sorts and de-duplicates edges" do
    dot = Dot.build("g", [{"b", "c"}, {"a", "b"}, {"a", "b"}])
    assert dot == ~s(digraph g {\n  rankdir=LR;\n  "a" -> "b";\n  "b" -> "c";\n}\n)
  end

  test "undirected collapses reversed pairs" do
    dot = Dot.build("g", [{"b", "a"}, {"a", "b"}], direction: :undirected)
    assert dot == ~s(graph g {\n  rankdir=LR;\n  "a" -- "b";\n}\n)
  end

  test "labels render and quotes escape" do
    dot = Dot.build("g", [{~s(a"x), "b", "12"}])
    assert dot == ~s(digraph g {\n  rankdir=LR;\n  "a\\"x" -> "b" [label="12"];\n}\n)
  end

  test "empty edge list still yields a valid graph" do
    assert Dot.build("g", []) == "digraph g {\n  rankdir=LR;\n\n}\n"
  end
end
