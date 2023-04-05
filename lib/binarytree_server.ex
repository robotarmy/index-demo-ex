defmodule BNode do
  defstruct [:key, :values, :left, :right]
end

defmodule BinaryTreeServer do
  @moduledoc """
   Please see the README for complexity information
  """
  use GenServer
  def default do
    %BNode{values: [], left: :empty, right: :empty, key: :empty}
  end

  def init(_args) do
    {:ok , default()}
  end

  def handle_cast({:insert, key, value}, state) do
    state = insert_key(state, key, value)
    {:noreply, state}
  end

  def handle_call({:traverse, count}, _calling_pid ,state) do
    response = traverse(count, state)
    {:reply, response, state}
  end

  def insert_key(:empty, key, value) do
    first_value(default(), key, value)
  end

  def insert_key(tree, key, value) do
    cond do
      tree.key == :empty ->
        first_value(tree, key, value)
      tree.key == key ->
        # duplicate - update in-place -
        # Keep duplicate values sorted in greater->least order
        %{tree | values: Enum.sort([value | tree.values]) |> Enum.reverse}
      tree.key > key ->
        # left
        %{tree | left: insert_key(tree.left, key, value) }
      tree.key < key ->
        # right
        %{tree | right: insert_key(tree.right, key, value) }
    end
  end

  def first_value(state, key, value) do
    %{state | key: key, values: [value]}
  end

  def traverse(count, tree, accum \\ [])
  #
  #
  # terminating condition - hit an empty branch
  # When we hit an empty branch we collapse the accumulator
  # and trucate the number of possible values accumulated
  #
  def traverse(count, :empty, accum) do
    accum |> List.flatten |> Enum.take(count)
  end

  # erlang supports tail call elimination and so this
  # must have recursion implemented as tail call to avoid stack growth.
  def traverse(count, tree, accum) when length(accum) < count do
    traverse(count, tree.left, [ traverse(count, tree.right, accum) | tree.values ])
  end

  #
  # This is a terminating case
  #
  # the accumulator has grown to be greater than the requested count
  # the list should be truncated
  #
  def traverse(count, _tree, accum) when length(accum) >= count do
    accum |> List.flatten |> Enum.take(count)
  end
end
