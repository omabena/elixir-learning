defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def init do
    %TodoList{}
  end

  def handle_cast({:add_entry, entry}, state) do
    add_entry(state, entry)
  end

  def handle_call({:entries, date}, state) do
    {entries(state, date), state}
  end

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

defmodule TodoServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  def add_entry(pid, entry) do
    cast(pid, {:add_entry, entry})
  end

  def get_entry(pid, date) do
    call(pid, {:entries, date})
  end

end
