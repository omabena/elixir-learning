defmodule Loop do
  defmacro while(expression, do: block) do
    try do
      quote do
        for _ <- Stream.cycle([:ok]) do
          if unquote(expression) do
            unquote(block)
          else
            IO.inspect("breaking")
            Loop.break()
          end
        end
      end
    catch
      :break -> :ok
    end
  end

  def break, do: throw(:break)
end
