defmodule Pkmn.Pokemon do
  defstruct(
    name: "",
    types: []
  )

  def make_from_json(data) do
    %Pkmn.Pokemon{
      name: data["name"],
      types: data["types"] |> Enum.map(& &1["type"]["name"])
    }
  end

  def mash_types(matchups, []), do: matchups
  def mash_types([{type, value} | tail], [{_, mod} | mash_tail]) do
    [{type, value * mod} | mash_types(tail, mash_tail)]
  end

  def calculate_matchups(_, []), do: []
  def calculate_matchups(matchups, [pokemon | team]) do
    [t1 | tail] = pokemon.types
    base_map = matchups[t1]
    map = case tail do
      [t2] -> mash_types(base_map, Map.get(matchups, t2, []))
      [] -> base_map
    end
    [map | calculate_matchups(matchups, team)]
  end

  def analyze_pokemon(_, []), do: []
  def analyze_pokemon([{type, mod} | pokemon], [{_, bad, good} | row]) do
    {bad, good} = cond do
      mod > 1.1 ->
        {bad, good + 1}
      mod < 0.9 ->
        {bad + 1, good}
      true -> {bad, good}
    end
    [{type, bad, good} | analyze_pokemon(pokemon, row)]
  end

  def analyze_matchups([], data), do: data
  def analyze_matchups([pokemon | team], data) do
    new_data = analyze_pokemon(pokemon, data)
    analyze_matchups(team, new_data)
  end

  # {type: normal, bad: 0, good: 0}
  def analyze_team(_, []), do: []
  def analyze_team(matchups, team) do
    types = Map.keys(matchups)
    data = Enum.map(types, &({&1, 0, 0}))
    calculate_matchups(matchups, team)
    |> analyze_matchups(data)
  end
end
