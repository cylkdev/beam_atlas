defmodule BeamAtlas.FixtureCase do
  @moduledoc "Compiles the fixture project once and exposes its path."
  @source Path.expand("fixture", __DIR__)

  def fixture_path do
    dest = Path.join(System.tmp_dir!(), "beam_atlas_fixture")

    unless File.dir?(Path.join(dest, "_build")) do
      File.rm_rf!(dest)
      File.cp_r!(@source, dest)
      {_, 0} = System.cmd("mix", ["compile"], cd: dest, env: [{"MIX_ENV", "dev"}])
    end

    dest
  end
end
