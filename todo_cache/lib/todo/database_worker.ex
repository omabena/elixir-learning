defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.inspect("Starting database worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(worker_pid, key, data) do
    GenServer.cast(via_tuple(worker_pid), {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(via_tuple(worker_pid), {:get, key})
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
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
