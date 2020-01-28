defmodule AdtTest do
  use ExUnit.Case
  doctest Adt

  test "greets the world" do
    assert Adt.hello() == :world
  end
end
