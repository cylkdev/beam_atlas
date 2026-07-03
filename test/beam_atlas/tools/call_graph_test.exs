defmodule BeamAtlas.Tools.CallGraphTest do
  use ExUnit.Case
  alias BeamAtlas.Tools.CallGraph

  test "spec advertises the elixir_call_graph tool and the query enum" do
    spec = CallGraph.spec()
    assert spec["name"] == "elixir_call_graph"
    assert "ME" in spec["inputSchema"]["properties"]["query"]["enum"]
  end

  test "call returns a content envelope with the module edge and dot" do
    path = BeamAtlas.FixtureCase.fixture_path()

    %{"content" => [%{"type" => "text", "text" => text}]} =
      CallGraph.call(%{"project_path" => path, "query" => "ME"})

    assert text =~ "GraphFixture.MemoryStorage"
    assert text =~ ~s("dot")
  end

  test "missing query returns an error envelope, not a crash" do
    path = BeamAtlas.FixtureCase.fixture_path()
    %{"content" => [%{"text" => text}]} = CallGraph.call(%{"project_path" => path})
    assert text =~ "error"
  end

  test "invalid query returns an error envelope, not a crash" do
    path = BeamAtlas.FixtureCase.fixture_path()
    %{"content" => [%{"text" => text}]} = CallGraph.call(%{"project_path" => path, "query" => "BOGUS"})
    assert text =~ "error"
  end
end
