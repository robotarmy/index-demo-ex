defmodule ServerInterfaceTest do
  use ExUnit.Case
  doctest Index


  test "implementations have same interface and produce compatable results " do
    [BinaryTreeServer, BTreeServer] |> Enum.each(fn module ->
      {:ok, server_pid} = GenServer.start_link(module, :ok)
      [[10, 100],[50, 200], [51, 200], [52,200], [100, 10000]] |> Enum.each(fn [v, k] ->
        GenServer.cast(server_pid, {:insert, k, v})
      end)

      # should find the value associated with max key
      result = GenServer.call(server_pid, {:traverse, 1})
      assert result == [100], "#{module} expected one element 100"

      # should find the value associated with max key and single
      # value from duplicate second maximal key
      result = GenServer.call(server_pid, {:traverse, 2})
      assert result == [100, 52], "#{module} expected elements 100, 52, #{inspect(result, charlists: :as_lists)}"


      # should find all the values in order
      result = GenServer.call(server_pid, {:traverse, 10})
      assert result == [100, 52, 51, 50, 10], "#{module} expected to find all entries #{inspect(result, charlists: :as_lists)}"

    end)

  end
end
