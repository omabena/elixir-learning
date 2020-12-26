defmodule BeliefStructure.Hexify do
  @moduledoc """
  Append a value to packages names
  """
  def name(package) do
    package(package)
  end

  defp package(package) do
    package <> "_ex"
  end
end
