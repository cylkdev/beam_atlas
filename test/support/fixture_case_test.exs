defmodule BeamAtlas.FixtureCaseTest do
  use ExUnit.Case
  test "fixture compiles and exposes an ebin" do
    path = BeamAtlas.FixtureCase.fixture_path()
    assert File.dir?(Path.join(path, "_build/dev/lib/graph_fixture/ebin"))
  end
end
