defmodule FormatterTest do
  use ExUnit.Case
  doctest Formatter

  test "greets the world" do
    assert Formatter.hello() == :world
  end
end
