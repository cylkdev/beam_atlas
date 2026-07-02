defprotocol GraphFixture.Greeter do
  @moduledoc false
  def greet(value)
end

defimpl GraphFixture.Greeter, for: BitString do
  def greet(name), do: "Hello, " <> name
end
