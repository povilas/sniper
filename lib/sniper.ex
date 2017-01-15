defmodule Sniper do

  require Logger
  use GenServer
  alias Sniper.ClientEvent
  alias Sniper.ClientCommand
  alias Sniper.ClientCommandHandler
  alias Sniper.AuctionCommand
  alias Sniper.AuctionEvent
  alias Sniper.AuctionEventHandler

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
      auction: nil,
      handler_state: %{
        id: "sniper",
        winning: false
      }
    }}
  end

  def handle_info(:accept_connection, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    {:noreply, %{state | client: client}}
  end

  def handle_info({:tcp, client, msg}, %{client: client} = state) do
    :inet.setopts(client, [active: :once])
    command = ClientCommand.decode(msg)

    state = if command == %ClientCommand.Start{} do
      {:ok, auction} = :gen_tcp.connect('localhost', 8080, [:binary, packet: :line, active: :once])
       %{state | auction: auction}
    else
      state
    end

    {:ok, msgs, handler_state} = ClientCommandHandler.handle(command, state.handler_state)
    send_messages(msgs, state)
    {:noreply, %{state | handler_state: handler_state}}
  end

  def handle_info({:tcp_closed, client}, %{client: client} = state) do
    send self(), :accept_connection
    {:noreply, %{state |
      client: nil,
      handler_state: %{
        id: "sniper",
        winning: false
      }
    }}
  end

  def handle_info({:tcp, auction, msg}, %{auction: auction} = state) do
    :inet.setopts(auction, [active: :once])
    event = AuctionEvent.decode(msg)
    {:ok, msgs, handler_state} = AuctionEventHandler.handle(event, state.handler_state)
    send_messages(msgs, state)
    {:noreply, %{state | handler_state: handler_state}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp send_messages([], _state), do: :ok

  defp send_messages([{:client, msg} | t], state) do
    raw = ClientEvent.encode(msg)
    :ok = :gen_tcp.send(state.client, raw)
    send_messages(t, state)
  end

  defp send_messages([{:auction, msg} | t], state) do
    raw = AuctionCommand.encode(msg)
    :ok = :gen_tcp.send(state.auction, raw)
    send_messages(t, state)
  end
end
