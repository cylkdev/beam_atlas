defmodule GraphFixture.MixProject do
  use Mix.Project

  def project, do: [app: :graph_fixture, version: "0.1.0", elixir: "~> 1.15", deps: []]
  def application, do: [extra_applications: [:logger], mod: {GraphFixture.Application, []}]
end
