defmodule BeamAtlas.Analyzer.CallsTest do
  use ExUnit.Case
  alias BeamAtlas.{Target, Analyzer.Calls}

  setup do
    {:ok, target} = Target.resolve(BeamAtlas.FixtureCase.fixture_path())
    {:ok, target: target}
  end

  test "module call graph shows GraphFixture -> MemoryStorage", %{target: target} do
    assert {:ok, edges} = Calls.edges(target, :ME)
    assert {"GraphFixture", "GraphFixture.MemoryStorage"} in edges
  end

  test "function call graph shows the store/2 -> put/2 edge", %{target: target} do
    assert {:ok, edges} = Calls.edges(target, :E)
    assert {"GraphFixture.store/2", "GraphFixture.MemoryStorage.put/2"} in edges
  end
end
