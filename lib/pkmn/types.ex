defmodule Pkmn.Types do
  def parse_row(_, []), do: []

  def parse_row([head | tail], [cell | row]) do
    mod =
      case cell do
        "=" -> 1.0
        "+" -> 2.0
        "-" -> 0.5
        "0" -> 0.0
      end

    [{head, mod} | parse_row(tail, row)]
  end

  def parse_types(_, []), do: []

  def parse_types(headers, [head | tail]) do
    [type | matchups] = head
    [{type, parse_row(headers, matchups)} | parse_types(headers, tail)]
  end

  def parse_types() do
    [headers | matchups] =
      with {:ok, file} = File.open("types.txt"),
           content = IO.read(file, :all),
           :ok = File.close(file),
           data =
             String.split(content, "\n")
             |> Enum.map(&String.split(&1)) do
        data
      end

    parse_types(headers, matchups)
    |> Enum.into(%{})
  end
end
