defmodule Util do
  def wait_for(message, timeout \\ 300) do
    receive do
      ^message -> true
    after timeout ->
      false
    end
  end
end
