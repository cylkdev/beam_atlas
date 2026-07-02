defmodule GraphFixture.Storage do
  @moduledoc false
  @callback put(term, term) :: :ok
  @callback get(term) :: term
end
