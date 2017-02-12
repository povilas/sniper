defmodule Sniper.ClientCommandTest do

  use ExUnit.Case
  import Sniper.ClientCommand, only: [decode: 1]
  alias Sniper.ClientCommand.Start

  test "decode start" do
    assert decode("START name,item\r\n") == {:ok, %Start{id: "name", item: "item", price: :undefined}}
    assert decode("START name,item,20\r\n") == {:ok, %Start{id: "name", item: "item", price: 20}}
  end

  test "return error for unknown command" do
    assert decode("FOOBAR") == {:error, {:unknown_command, "FOOBAR"}}
  end

end
