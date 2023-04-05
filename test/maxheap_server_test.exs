
defmodule  MaxHeapServerTest do
  use ExUnit.Case
  doctest MaxHeapServer

  @doc """
   This test the properties desired for a datastructure
   that operates as a non unique heap based index
   it supports duplicate index entries  (multi match)

  """

  alias MaxHeapServer, as: M
  test " inserting key element multiple times modifies internal map, sets heap value" do
    state =
    M.default()
    |> M.insert_key(10, "A")
    |> M.insert_key(10, "B" )
    |> M.insert_key(10, "C" )
    |> M.insert_key(10, "D" )

    expected_values = ["A", "B", "C", "D"] # in min -> max 
    result = Map.get(state.map, 10)
    assert result == expected_values,
      " internal datastructure stores heap values #{inspect(result, charlists: :as_lists)}"

    key = state.heap |> Heap.root()
    assert key == 10 , "expected key 10 stored in heap, found #{key}"
  end

  test "traverse with multiple elements for 1 key" do
    state =
      M.default()
      |> M.insert_key(10, "A")
      |> M.insert_key(10, "B" )
      |> M.insert_key(10, "C" )
      |> M.insert_key(10, "D" )
    expected_values = ["D", "C", "B", "A"] # max -> min
    result = M.traverse(state,5)
    assert result == expected_values,
      "traverse returns same as direct map request #{inspect(result, charlists: :as_lists)}"
  end

  test "traverse with multiple elements for many keys" do
    state =
      M.default()
      |> M.insert_key(10, "A")
      |> M.insert_key(100, "B" )
      |> M.insert_key(200, "C" )
      |> M.insert_key(300, "D" )
    expected_values = ["D", "C"]
    result = M.traverse(state,2)
    assert result == expected_values,
      "traverse returns top 2 key matches request #{inspect(result, charlists: :as_lists)}"
  end

end
