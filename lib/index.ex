defmodule Index do
  @moduledoc """
   This is a wrapper
  """
  def process_line(line, server) do
    String.trim(line) |> String.split(" ") |> then(fn [value, key] ->
      with {value_int, _ } <- Integer.parse(value),  {key_int, _}<- Integer.parse(key) do
        # Send a message to the Server process to execute insert 
        GenServer.cast(server, {:insert, key_int, value_int})
      else
        skipped ->
          IO.puts("--[WARN]- Input [#{skipped}] -SKIPPED---")
        end
    end)
    server
  end

  def execute_alg(module, [], key_count) do
    IO.puts("--FILE: STDIN---")
    IO.puts ("-[QUERYING TOP #{key_count} entries]---")
    execute_from_stdin(module, key_count)
  end

  def execute_alg(module, [file], key_count) do
    case File.exists?(file) do
      false ->
        IO.puts("Filename #{file} does not exisit.")
      true ->
        IO.puts("--FILE: #{file}---")
        IO.puts("-[Displaying values of TOP #{key_count} keys]---")
        execute_from_file(module, file, key_count)
    end
  end

  def execute_from_file(module, file, count) do
    {:ok, server} = GenServer.start_link(module, :ok)
    Enum.reduce(File.stream!(file, [], :line), server , &process_line(&1, &2))
    GenServer.call(server, {:traverse, count}, :infinity) |> Enum.each(&IO.puts(&1))
  end

  def execute_from_stdin(module, count) do
    {:ok, server} = GenServer.start_link(module, :ok)
    Enum.reduce(IO.stream(:stdio, :line), server , &process_line(&1, &2))
    GenServer.call(server, {:traverse, count}, :infinity) |> Enum.each(&IO.puts(&1))
  end

  def generate_dataset(file, count) do
    # use delayed write to cause file write operation to be bufferred
    Stream.map(0..count, fn  _idx ->
      "#{Enum.random(100_000_000..999_9999_999_999)} #{Enum.random(1..9_999_999)}\n"
    end) |> Stream.into(File.stream!(file,[:delayed_write,:utf8])) |> Stream.run
  end

  def main(args) do
    parsed = args |> OptionParser.parse(strict: [X: :integer,
                                                 generate: :integer,
                                                 btree: :boolean,
                                                 binarytree: :boolean,
                                                 heap: :boolean])
    case parsed do
      {[X: key_count], file_or_stdin, []} ->
        execute_alg(BTreeServer, file_or_stdin, key_count)
      {[heap: true, X: key_count], file_or_stdin, []} ->
        execute_alg(MaxHeapServer, file_or_stdin, key_count)
      {[btree: true, X: key_count], file_or_stdin, []} ->
        execute_alg(BTreeServer, file_or_stdin, key_count)
      {[binarytree: true, X: key_count], file_or_stdin , []} ->
        execute_alg(BinaryTreeServer, file_or_stdin, key_count)
      {[generate: _count], [], []} ->
        IO.puts("-- Specify output filename for generated dataset please.")
        IO.puts"./index filename --generate=number_of_lines "
      {[generate: count], [file], []} ->
        IO.puts("generating data set")
        generate_dataset(file, count)
      _ ->
        IO.puts("-[Help]-------")
        IO.puts("> optional: ")
        IO.puts(">  *  --btree : balanced tree implementation ")
        IO.puts(">     --binarytree : naive binary tree implementation ")
        IO.puts(">     --heap : max heap based implementation ")
        IO.puts("> *default")
        IO.puts(">-------------")
        IO.puts(">./index file-to-read --X=3")
        IO.puts(">\t process file and print top index values")
        IO.puts(">")
        IO.puts(">cat file-to-read | ./index --X=3")
        IO.puts(">\t process file-to-read via standard input and print top index values")
        IO.puts(">")
        IO.puts(">./index output-file --generate=number_of_lines")
        IO.puts(">\t stream a random test dataset to <file>")
        IO.puts("---------[End]")
        IO.inspect(parsed)
    end
    System.halt(1)
  end

end
