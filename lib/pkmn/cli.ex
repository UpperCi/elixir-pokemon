defmodule Pkmn.CLI do
  def main(argv) do
    args = parse_args(argv)

    {:ok, team} =
      case args do
        :help -> "Help"
        :invalid -> "Invalid arguments. Use --help for more info."
        _ -> args |> Pkmn.API.get_team()
      end

    types = Pkmn.Types.parse_types()

    IO.puts("===== Team analyzation =====\n")
    IO.puts("Type      | Strong | Weak ")
    IO.puts("----------------------------")
    Pkmn.Pokemon.analyze_team(types, team)
    |> print_data
  end

  def print_data(data) do
    Enum.each(data, fn {type, good, bad} ->
      IO.puts("#{String.pad_trailing(type, 10, " ")}| #{good}      | #{bad}") end)
  end

  def parse_args(argv) do
    args =
      OptionParser.parse(argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    args |> args_to_internal
  end

  def args_to_internal({[help: true], _, _}), do: :help
  def args_to_internal({_, [], _}), do: :invalid
  def args_to_internal({_, pokemon, _}), do: pokemon
end
