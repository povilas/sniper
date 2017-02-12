defmodule Sniper do

  require Logger
  use GenServer
  alias Sniper.ClientEvent
  alias Sniper.ClientCommand
  alias Sniper.ClientCommandHandler
  alias Sniper.AuctionCommand
  alias Sniper.AuctionEvent
  alias Sniper.AuctionEventHandler

  def start(client) do
    GenServer.start(__MODULE__, client)
  end

  def init(client) do
    {:ok, auction} = :gen_tcp.connect('localhost', 8080, [:binary, packet: :line, active: :once])
    {:ok, %{
      client: client,
      auction: auction,
      handler_state: %{
        id: "sniper",
        item: nil,
        stop_price: :undefined,
        last_bid: nil,
        winning: false
      }
    }}
  end

  def handle_info({:tcp, client, msg}, %{client: client} = state) do
    :inet.setopts(client, [active: :once])
    case ClientCommand.decode(msg) do
      {:ok, command} ->
        {:ok, msgs, handler_state} = ClientCommandHandler.handle(command, state.handler_state)
        state = %{state | handler_state: handler_state}
        send_messages(msgs, state)
        {:noreply, state}
      {:error, reason} ->
        :ok = :gen_tcp.send(state.client, "Error: #{inspect reason}\r\v")
        {:noreply, state}
    end
  end

  def handle_info({:tcp_closed, client}, %{client: client} = state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp, auction, msg}, %{auction: auction} = state) do
    :inet.setopts(auction, [active: :once])
    event = AuctionEvent.decode(msg)
    {:ok, msgs, handler_state} = AuctionEventHandler.handle(event, state.handler_state)
    send_messages(msgs, state)
    {:noreply, %{state | handler_state: handler_state}}
  end

  def handle_info({:tcp_closed, auction}, %{auction: auction} = state) do
    {:stop, :normal, state}
  end

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
