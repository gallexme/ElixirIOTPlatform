defmodule AppSystemTest do
  use ExUnit.Case
  doctest AppSystem

  test "greets the world" do
    assert AppSystem.hello() == :world
  end
end
