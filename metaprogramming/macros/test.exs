defmodule Test do
  import Assertion

  def run do
    assert 5 == 5
    assert 2 > 0
    assert 10 < 1
  end
end
