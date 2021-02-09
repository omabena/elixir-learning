defmodule MathTest do
   use Assertion

   test "integer can be added an substracted" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 10
    assert 4 - 3 == 10
   end 

   test "integer can be multiplied an divided" do
    assert 1 * 1 == 1
    assert 10 / 2 == 5
   end 
end
