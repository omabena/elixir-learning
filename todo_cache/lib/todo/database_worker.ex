defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @impl true
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl true
  def handle_cast({:store, key, data}, db_folder) do
    {key, db_folder}
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  @impl true
  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name({key, db_folder})) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name({key, db_folder}) do
    Path.join(db_folder, to_string(key))
  end
end
