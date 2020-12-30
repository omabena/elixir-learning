defmodule PathAllocator do
  use GenServer

  @name PathAllocator

  def start_link(tmp_dir) when is_binary(tmp_dir) do
    GenServer.start_link(__MODULE__, tmp_dir, name: @name)
  end

  def allocate do
    GenServer.call(@name, :allocate)
  end

  def init(tmp_dir) do
    {:ok, {tmp_dir, %{}}}
  end

  def handle_call(:allocate, {pid, _}, {tmp_dir, refs}) do
    path = Path.join(tmp_dir, generate_random_filename())
    ref = Process.monitor(pid)
    refs = Map.put(refs, ref, path)
    {:reply, path, {tmp_dir, refs}}
  end

  defp generate_random_filename do
    Base.url_encode64(:crypto.strong_rand_bytes(48))
  end

  def handle_info({:DOWN, ref, _, _, _}, {tmp_dir, refs}) do
    {path, refs} = Map.pop(refs, ref)
    File.rm(path)
    {:noreply, {tmp_dir, refs}}
  end

end
