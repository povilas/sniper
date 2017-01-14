defmodule Sniper.ClientEvent do

  defmodule Lost, do: defstruct []
  defmodule Bidding, do: defstruct []

  def encode(%Lost{}), do: "LOST\r\n"
  def encode(%Bidding{}), do: "I'M BIDDING\r\n"
  
end
