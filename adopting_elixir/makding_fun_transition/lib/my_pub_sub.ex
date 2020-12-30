defmodule MyPubSub do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end
 
  def init(init_arg) do
    {:ok, init_arg}
  end
end
