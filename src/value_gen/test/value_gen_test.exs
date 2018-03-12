defmodule ValueGenTest do
  use ExUnit.Case
  doctest ValueGen

  test "greets the world" do
    assert ValueGen.hello() == :world
  end
end
