defmodule Assertion do
  # {:==, [context: Elixir, import: Kernel], [5, 5]}
  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quote: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end
