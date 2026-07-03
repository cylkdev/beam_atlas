defmodule BeamAtlas.Tools.RuntimeGraphTest do
  use ExUnit.Case
  alias BeamAtlas.Tools.RuntimeGraph

  # The happy path needs a live remote node (node + cookie), which the test
  # suite has no way to stand up; the runtime graph assembly itself is covered
  # by BeamAtlas.Analyzer.Runtime's unit tests. Here we cover the tool contract:
  # the advertised spec and graceful handling of malformed input.

  test "spec advertises the elixir_runtime_graph tool with the runtime kinds" do
    spec = RuntimeGraph.spec()
    assert spec["name"] == "elixir_runtime_graph"
    assert "supervision" in spec["inputSchema"]["properties"]["kind"]["enum"]
  end

  test "invalid kind returns an error envelope, not a crash" do
    %{"content" => [%{"text" => text}]} =
      RuntimeGraph.call(%{"node" => "n@h", "cookie" => "c", "kind" => "nope"})

    assert text =~ "error"
  end

  test "missing required keys returns an error envelope" do
    %{"content" => [%{"text" => text}]} = RuntimeGraph.call(%{"kind" => "supervision"})
    assert text =~ "error"
  end
end
