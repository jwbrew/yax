defmodule YaxTest do
  use ExUnit.Case
  doctest Yax

  test "greets the world" do
    assert Yax.hello() == :world
  end
end
