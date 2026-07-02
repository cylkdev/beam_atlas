defmodule BeamAtlas.Analyzer.MixGraphsTest do
  use ExUnit.Case
  alias BeamAtlas.{Target, Analyzer.MixGraphs}

  setup do
    {:ok, target} = Target.resolve(BeamAtlas.FixtureCase.fixture_path())
    {:ok, target: target}
  end

  test "source_files graph is DOT mentioning a fixture file", %{target: target} do
    assert {:ok, dot} = MixGraphs.dot(target, :source_files)
    assert dot =~ "digraph"
    assert dot =~ "lib/graph_fixture.ex"
  end

  test "applications graph is DOT", %{target: target} do
    assert {:ok, dot} = MixGraphs.dot(target, :applications)
    assert dot =~ "digraph"
  end
end
