defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  # def new(), do: %TodoList{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc -> add_entry(todo_list_acc, entry) end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    Map.delete(todo_list, entry_id)
  end

  defimpl Collectable, for: TodoList do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(todo_list, :halt), do: :ok
  end
end

defmodule TodoList.CsvImporter do
    def import(file) do
        File.stream!(file)
        |> Stream.map(fn line ->
            String.replace(line, "\n", "")
            |> String.replace(" ", "")
            end)
        |> Stream.map(fn line ->
            [date, title] = String.split(line, ",", trim: true)
            [year, month, date] = String.split(date,"/", trim: true)
            {{String.to_integer(year), String.to_integer(month), String.to_integer(date)}, title}
            end)
        |> Enum.map(fn entry ->
            {{year, month, date}, title} = entry
            {_, d} = Date.new(year, month, date)
            %{date: d, title: title}
            end)
    end
end

defmodule TodoServer do
  def start do
    pid = spawn(fn -> loop(TodoList.new()) end)
    Process.register(pid, :todo_server)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

      loop(new_todo_list)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end

  end

end
