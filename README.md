# Riot

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `Riot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:riot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/Riot>.

## Starting Application
Small project to demonstrate elixir use.

1) The application will taking a username and platform defined in the config.exs file
2) Retrieve the API information from Riot about the player
3) Find the last two matches played
4) Get the participants from those matches
  a) Will be printed to IO as:
    > [player1, player2, ...etc]
5) Monitor all players for new matches completed every 60 seconds
  a) Completed matches will print as:
    > Summoner "player name" completed match "match id"
6) Processes will shutdown after an hour

You will need to get an x_riot_token key from riot here: https://developer.riotgames.com/

API endpoints used:
  https://developer.riotgames.com/apis#match-v5/GET_getMatchIdsByPUUID
  https://developer.riotgames.com/apis#match-v5/GET_getMatch
  https://developer.riotgames.com/apis#summoner-v4/GET_getBySummonerName