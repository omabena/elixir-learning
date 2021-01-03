defmodule Formatter do
  @moduledoc """
  Documentation for `Formatter`.
  """

  def json_formatter(level, message, time, metadata) do
    message = IO.chardata_to_string(message)
    [encode_to_json(level, message, time, Map.new(metadata)), ?\n]
  end

  defp encode_to_json(level, message, _time, metadata) do
    Poison.encode!(%{
      level: level,
      message: message,
      metadata: metadata
    })
  rescue
    _ ->
      Poison.encode!(%{
        level: level,
        message: "error while formatting #{inspect(message)} with
        #{inspect(metadata)}",
        metadata: %{}
      })
  end
end
