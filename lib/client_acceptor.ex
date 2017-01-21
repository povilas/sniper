defmodule ClientAcceptor do

  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_tcp.listen(8081, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Sniper listening on 8081"
    send self(), :accept_client
    {:ok, %{socket: socket}}
  end

  def handle_info(:accept_client, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    {:ok, handler_pid} = Sniper.start(client)
    :ok = :gen_tcp.controlling_process(client, handler_pid)
    :inet.setopts(client, [active: :once])
    send self(), :accept_client
    {:noreply, state}
  end

end
