defmodule BeamAtlas.ServerTest do
  use ExUnit.Case
  alias BeamAtlas.Server

  test "get_tools exposes exactly the four graph tools" do
    names = Server.get_tools() |> Map.keys() |> Enum.sort()

    assert names == ~w(
             elixir_call_graph
             elixir_implementation_graph
             elixir_mix_graph
             elixir_runtime_graph
           )
  end

  test "call-graph tool returns an envelope with the module edge" do
    path = BeamAtlas.FixtureCase.fixture_path()

    {:ok, %{content: [%{"text" => text}]}, _state} =
      Server.handle_tool_call(
        "elixir_call_graph",
        %{"project_path" => path, "query" => "ME"},
        %{}
      )

    assert text =~ "GraphFixture.MemoryStorage"
    assert text =~ ~s("dot")
  end

  test "implementation-graph tool returns behaviour and protocol edges" do
    path = BeamAtlas.FixtureCase.fixture_path()

    {:ok, %{content: [%{"text" => text}]}, _state} =
      Server.handle_tool_call(
        "elixir_implementation_graph",
        %{"project_path" => path, "kind" => "both"},
        %{}
      )

    assert text =~ "GraphFixture.Storage"
    assert text =~ "GraphFixture.Greeter"
  end

  test "mix-graph tool returns DOT for source_files" do
    path = BeamAtlas.FixtureCase.fixture_path()

    {:ok, %{content: [%{"text" => text}]}, _state} =
      Server.handle_tool_call(
        "elixir_mix_graph",
        %{"project_path" => path, "kind" => "source_files"},
        %{}
      )

    assert text =~ "digraph"
  end

  test "call-graph tool returns an error envelope (not a crash) when query is missing" do
    path = BeamAtlas.FixtureCase.fixture_path()

    {:ok, %{content: [%{"text" => text}]}, _state} =
      Server.handle_tool_call(
        "elixir_call_graph",
        %{"project_path" => path},
        %{}
      )

    assert text =~ "error"
  end

  test "call-graph tool returns an error envelope (not a crash) when query is invalid" do
    path = BeamAtlas.FixtureCase.fixture_path()

    {:ok, %{content: [%{"text" => text}]}, _state} =
      Server.handle_tool_call(
        "elixir_call_graph",
        %{"project_path" => path, "query" => "BOGUS"},
        %{}
      )

    assert text =~ "error"
  end
end
