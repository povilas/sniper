defmodule Util do
  def wait_for(message, timeout \\ 100) do
    receive do
      ^message -> true
    after timeout ->
      false
    end
  end
end
