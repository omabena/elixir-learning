defmodule KeyValueStore do
  use GenServer

  def start do
    GenServer.start(KeyValueStore, nil)
  end

  @impl GenServer
  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts "performing cleanup..."
    {:noreply, state}
  end

end
