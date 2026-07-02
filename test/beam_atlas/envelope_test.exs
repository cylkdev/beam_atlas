defmodule BeamAtlas.EnvelopeTest do
  use ExUnit.Case
  alias BeamAtlas.Envelope

  test "edges array is sorted and de-duplicated" do
    json = Envelope.edges([{"b", "a"}, {"a", "b"}, {"a", "b"}], "g")
    decoded = Jason.decode!(json)

    assert decoded["edges"] == [["a", "b"], ["b", "a"]]
  end
end
