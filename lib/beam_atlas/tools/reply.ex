defmodule BeamAtlas.Tools.Reply do
  @moduledoc "Wraps a JSON payload string in an MCP text-content result map."

  def text(payload) do
    %{"content" => [%{"type" => "text", "text" => payload}]}
  end
end
