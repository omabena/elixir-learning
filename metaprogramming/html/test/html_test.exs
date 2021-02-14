defmodule HtmlTest do
  use ExUnit.Case
  doctest Html

  test "greets the world" do
    assert Html.hello() == :world
  end
end
