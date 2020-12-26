defmodule BeliefStructure do
  @moduledoc """
  Module to hexify packages
  """

  alias BeliefStructure.Hexify

  def hexify(package) do
    case String.ends_with?(package, "ex") do
      true -> package
      false -> Hexify.name(package)
    end
  end
end
