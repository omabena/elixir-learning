defmodule BeliefStructure do
  @doc """
  Adds the "_ex" suffix to the package name if necessary.

  ## Examples
    iex > BeliefStructure.hexify("math_ex")
    "math_ex"

  """

  alias BeliefStructure.Hexify

  @spec hexify(String.t()) :: String.t()
  def hexify(package) do
    case String.ends_with?(package, "ex") do
      true -> package
      false -> Hexify.name(package)
    end
  end
end
