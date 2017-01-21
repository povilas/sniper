defmodule Sniper.ClientCommand do

  defmodule Start, do: defstruct [:id, :item, :price]

  def decode("START" <> msg) do
    case msg |> String.trim |> String.split(",") do
      [id, item, price] -> %Start{id: id, item: item, price: String.to_integer(price)}
      [id, item] -> %Start{id: id, item: item, price: :undefined}
    end
  end

end
