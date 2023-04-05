defmodule MaxHeapServer do
  @moduledoc """
  Please see the README for complexity information
  """
  use GenServer
  def default do
    %{heap: Heap.max(), map: Map.new()}
  end

  def init(_args) do
    {:ok , default()}
  end

  def handle_cast({:insert, key, value}, state) do
    state = insert_key(state, key, value)
    {:noreply, state}
  end

  def handle_call({:traverse, count}, _calling_pid, state) do
    response = traverse(state, count)
    {:reply, response, state}
  end

  def traverse(state, count, accum \\ [])
  def traverse(_state, count, accum) when length(accum) >= count do
    accum |> List.flatten |> Enum.reverse |> Enum.take(count)
  end
  def traverse(state, count, accum) do
    max = Heap.root(state.heap)
    new_heap = Heap.pop(state.heap)
    case Heap.empty?(new_heap) do
      true ->
        [ Map.get(state.map, max) | accum]
        |> List.flatten
        |> Enum.reverse
      false ->
        new_state = %{state | heap: new_heap }
        traverse(new_state, count, [ Map.get(state.map, max)| accum])
    end
  end

  def insert_key(state, key, value) do
    case Heap.member?(state.heap, key) do
      # already seen this value it is part of heap
      true ->
        { _prev_value, new_map } =
          Map.get_and_update(
            state.map,
            key,
            fn current_value ->
              {
                current_value,
                [value | current_value] |> Enum.sort
              }
            end)
        # heap is unchanged
        %{ state |  map: new_map }
        # new value - heap and map change
      false ->
        new_heap = Heap.push(state.heap, key)
        new_map = Map.put(state.map, key, [value])
        %{ heap: new_heap, map: new_map }
    end
  end
end

