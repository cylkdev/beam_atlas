defmodule BeamAtlas.Tools.ImplementationGraphTest do
  use ExUnit.Case
  alias BeamAtlas.Tools.ImplementationGraph

  test "spec advertises the elixir_implementation_graph tool" do
    assert ImplementationGraph.spec()["name"] == "elixir_implementation_graph"
  end

  test "call both returns behaviour and protocol edges" do
    path = BeamAtlas.FixtureCase.fixture_path()

    %{"content" => [%{"text" => text}]} =
      ImplementationGraph.call(%{"project_path" => path, "kind" => "both"})

    assert text =~ "GraphFixture.Storage"
    assert text =~ "GraphFixture.Greeter"
  end

  test "invalid kind returns an error envelope" do
    path = BeamAtlas.FixtureCase.fixture_path()
    %{"content" => [%{"text" => text}]} = ImplementationGraph.call(%{"project_path" => path, "kind" => "nope"})
    assert text =~ "error"
  end
end
