defmodule Pkmn.API do
  def get_all_pokemon() do
    {:ok, body} = HTTPoison.get("https://pokeapi.co/api/v2/pokemon?limit=10000")
    |> handle_response
    Jason.decode!(body)["results"]
    |> Enum.map(&(&1["name"]))
  end

  def similar_names(name) do
    get_all_pokemon()
    |> Enum.map(&({String.jaro_distance(&1, name), &1}))
    |> Enum.filter(fn ({dist, _}) -> dist > 0.75 end)
    |> Enum.sort(fn ({a, _}, {b, _}) -> a >= b end)
    |> Enum.map(fn ({_, name}) -> name end)
  end

  def suggest([]), do: nil
  def suggest([new_name | tail]) do
    answer = IO.gets("Did you mean #{new_name}? [y/n] ")
    |> String.downcase
    if String.starts_with?(answer, "y") do
      new_name
    else
      suggest(tail)
    end
  end

  def get_team([]), do: {:ok, []}
  def get_team([head | tail]) do
    {result, body} = get_pokemon(head)

    case result do
      {:error, _status} ->
        IO.puts("Can't find #{head}")
        new_pkmn = head
        |> similar_names
        |> suggest
        |> IO.inspect
        if new_pkmn != nil do
          get_team([new_pkmn | tail])
        else
          {:error, "Can't analyze team, pokemon not found: #{head}"}
        end

      :ok ->
        case get_team(tail) do
          {:ok, res} ->
            {:ok,
             [
               body
               |> Jason.decode!()
               |> Pkmn.Pokemon.make_from_json()
               | res
             ]}

          res ->
            res
        end
    end
  end

  def get_pokemon(pokemon) do
    HTTPoison.get("https://pokeapi.co/api/v2/pokemon/#{pokemon}")
    |> handle_response
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, body}
  end

  def handle_response({:ok, %{status_code: status, body: body}}) do
    {{:error, status}, body}
  end
end
