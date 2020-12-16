defmodule SimpleRegistry do
  use GenServer

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  @spec init(any) :: {:ok, %{}}
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @spec register(any) :: any
  def register(key) do
    GenServer.call(__MODULE__, {:register, key, self()})
  end

  @spec whereis(any) :: any
  def whereis(key) do
    GenServer.call(__MODULE__, {:whereis, key})
  end

  @impl true
  def handle_call({:register, key, pid}, _, state) do
    case Map.get(state, key) do
      nil ->
        Process.link(pid)
        {:reply, :ok, Map.put(state, key, pid)}

      _ ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:whereis, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    {:noreply, deregister_pid(state, pid)}
  end

  defp deregister_pid(process_registry, pid) do
    process_registry
    |> Enum.reject(fn {_key, registered_process} -> registered_process == pid end)
    |> Enum.into(%{})
  end
end
