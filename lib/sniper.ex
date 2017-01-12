defmodule Sniper do
  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_tcp.listen(8081, [:binary, packet: :line, active: :once, reuseaddr: true])
    Logger.info "Sniper listening on 8081"
    send self(), :accept_connection
    {:ok, %{
      socket: socket,
      client: nil,
      auction: nil
    }}
  end

  def handle_info(:accept_connection, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    {:noreply, %{state | client: client}}
  end

  def handle_info({:tcp, client, msg}, %{client: client} = state) do
    :inet.setopts(client, [active: :once])
    {:noreply, handle_client(msg, state)}
  end

  def handle_info({:tcp, auction, msg}, %{auction: auction} = state) do
    :inet.setopts(auction, [active: :once])
    {:noreply, handle_auction(msg, state)}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  def handle_client("START" <> _, state) do
    {:ok, auction} = :gen_tcp.connect('localhost', 8080, [:binary, packet: :line, active: :once])
    Logger.info "Sniper joining auction"
    :ok = :gen_tcp.send(auction, "JOIN\r\n")
    %{state| auction: auction}
  end

  def handle_auction("LOST" <> _, state) do
    Logger.info "Sniper lost auction"
    :ok = :gen_tcp.send(state.client, "LOST\r\n")
    state
  end
end
