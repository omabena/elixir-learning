defmodule Todo.DatabaseWorker do
  use GenServer

  @spec start(any) :: :ignore | {:error, any} | {:ok, pid}
  def start(folder) do
    IO.inspect("Starting database server.")
    GenServer.start(__MODULE__, folder)
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
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
