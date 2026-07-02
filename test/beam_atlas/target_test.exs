defmodule BeamAtlas.TargetTest do
  use ExUnit.Case
  alias BeamAtlas.Target

  test "resolves a compiled fixture to its app ebin" do
    path = BeamAtlas.FixtureCase.fixture_path()
    assert {:ok, target} = Target.resolve(path)
    assert target.path == path
    assert Enum.any?(target.app_ebins, &String.ends_with?(to_string(&1), "graph_fixture/ebin"))
    assert target.all_ebins != []
    assert Enum.any?(target.all_ebins, &String.ends_with?(to_string(&1), "graph_fixture/ebin"))
  end

  test "include_deps: true populates app_ebins with all ebins" do
    path = BeamAtlas.FixtureCase.fixture_path()
    assert {:ok, target} = Target.resolve(path, include_deps: true)
    assert Enum.any?(target.app_ebins, &String.ends_with?(to_string(&1), "graph_fixture/ebin"))
  end

  test "errors on a non-Mix path" do
    assert {:error, _} = Target.resolve(System.tmp_dir!())
  end
end
