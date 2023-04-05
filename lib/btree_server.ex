defmodule BTreeServer do
  @moduledoc """
  Please see the README for complexity information
  """
  use GenServer
  def default do
    :gb_trees.empty()
  end

  def init(_args) do
    {:ok , default()}
  end

  def handle_cast({:insert, key, value}, state) do
    state = case :gb_trees.lookup(key, state) do
      {:value, found_value} ->
        :gb_trees.enter(key, Enum.sort([value | found_value]), state)
      :none ->
        :gb_trees.enter(key, [value], state)
    end

    {:noreply, state}
  end

  def handle_call({:traverse, count}, _calling_pid, state) do
    response = get_largest(count, state)
    {:reply, response, state}
  end

  # duplicate values found in a signle key
  # will be returned in greater to least order
  def get_largest(count, tree, accum \\ [])
  def get_largest(count, _tree, accum) when length(accum) == count do
    # accum may have multiple values for a given key
    # we have pulled count keys out of the tree
    # and we now flatten those values and take the top
    accum |> List.flatten |> Enum.reverse |> Enum.take(count)
  end

  # get N values of the largest keys where N == count
  def get_largest(count, tree, accum) do
    {_key, value, tree2} = :gb_trees.take_largest(tree)
    case :gb_trees.is_empty(tree2) do
      true ->
        [value | accum] |> List.flatten |> Enum.reverse
      false ->
        get_largest(count, tree2, [value | accum ])
    end
  end
end
