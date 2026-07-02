defmodule BeamAtlas.Analyzer.ImplementationsTest do
  use ExUnit.Case
  alias BeamAtlas.{Target, Analyzer.Implementations}

  setup do
    {:ok, target} = Target.resolve(BeamAtlas.FixtureCase.fixture_path())
    {:ok, target: target}
  end

  test "behaviours edge Storage -> MemoryStorage", %{target: target} do
    assert {:ok, edges} = Implementations.behaviours(target)
    assert {"GraphFixture.Storage", "GraphFixture.MemoryStorage"} in edges
  end

  test "protocols edge Greeter -> BitString", %{target: target} do
    assert {:ok, edges} = Implementations.protocols(target)
    assert {"GraphFixture.Greeter", "BitString"} in edges
  end
end
