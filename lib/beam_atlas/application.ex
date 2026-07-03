defmodule BeamAtlas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if release?() do
        [{BeamAtlas.StdioServer, halt_on_eof: true}]
      else
        []
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BeamAtlas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Mix is not available inside a release (e.g. a Burrito binary); in dev/test
  # the server is started explicitly via `mix beam_atlas.stdio` instead so we
  # never hijack stdin under iex or ExUnit.
  defp release?, do: not Code.ensure_loaded?(Mix)
end
