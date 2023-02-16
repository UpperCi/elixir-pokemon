defmodule PkmnTest do
  use ExUnit.Case
  doctest Pkmn

  test "greets the world" do
    assert Pkmn.hello() == :world
  end

  test "-h and --help return help atom" do
    assert Pkmn.CLI.main(["-h"]) == :help
    assert Pkmn.CLI.main(["--help"]) == :help
  end
end
