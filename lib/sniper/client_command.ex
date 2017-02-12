defmodule Sniper.ClientCommand do

  defmodule Start, do: defstruct [:id, :item, :price]

  def decode("START" <> msg) do
    case msg |> String.trim |> String.split(",") do
      [id, item, price] -> {:ok, %Start{id: id, item: item, price: String.to_integer(price)}}
      [id, item] -> {:ok, %Start{id: id, item: item, price: :undefined}}
    end
  end

  def decode(msg) do
    {:error, {:unknown_command, msg}}
  end

end
