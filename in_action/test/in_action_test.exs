defmodule InActionTest do
  use ExUnit.Case
  doctest InAction

  test "greets the world" do
    assert InAction.hello() == :world
  end
end
