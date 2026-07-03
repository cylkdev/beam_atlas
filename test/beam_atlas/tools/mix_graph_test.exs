defmodule BeamAtlas.Tools.MixGraphTest do
  use ExUnit.Case
  alias BeamAtlas.Tools.MixGraph

  test "spec advertises the elixir_mix_graph tool" do
    assert MixGraph.spec()["name"] == "elixir_mix_graph"
  end

  test "call source_files returns DOT" do
    path = BeamAtlas.FixtureCase.fixture_path()
    %{"content" => [%{"text" => text}]} = MixGraph.call(%{"project_path" => path, "kind" => "source_files"})
    assert text =~ "digraph"
  end

  test "invalid kind returns an error envelope" do
    path = BeamAtlas.FixtureCase.fixture_path()
    %{"content" => [%{"text" => text}]} = MixGraph.call(%{"project_path" => path, "kind" => "nope"})
    assert text =~ "error"
  end
end
