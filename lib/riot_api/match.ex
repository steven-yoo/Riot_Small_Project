defmodule Riot.RiotAPI.Match do
  require Logger

  alias Riot.RiotAPI.Summoner
  alias Riot.RiotAPI.APIHelper

  @type maybe_matches ::
          {:ok, list(String.t)} | {:error, :failed_request}
  @type maybe_participants ::
          {:ok, list(Summoner.t())} | {:error, :failed_request}

  @spec get_matches(String.t(), String.t()) :: maybe_matches()
  def get_matches(puuid, region) do
    url = APIHelper.get_base_region_url(region) <> "match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=2"

    case Riot.RiotAPI.APIHelper.send_get_request(url) do
      {:ok, matches} -> {:ok, matches}
      {:error, _} -> {:error, :failed_request}
    end
  end

  @spec get_last_matches(String.t(), String.t(), integer()) :: maybe_matches()
  def get_last_matches(puuid, region, timestamp) do
    url = APIHelper.get_base_region_url(region) <> "match/v5/matches/by-puuid/#{puuid}/ids?startTime=#{timestamp}"

    case Riot.RiotAPI.APIHelper.send_get_request(url) do
      {:ok, matches} -> {:ok, matches}
      {:error, _} -> {:error, :failed_request}
    end
  end

  @spec get_players_from_match(String.t(), String.t()) :: maybe_participants()
  def get_players_from_match(match_id, region) do
    url = APIHelper.get_base_region_url(region) <> "match/v5/matches/#{match_id}"

    with {:ok, response} <- Riot.RiotAPI.APIHelper.send_get_request(url),
         {:ok, players} <- parse_players(response) do
      {:ok, players}
    else
      {:error, _} ->
        {:error, :failed_request}
    end
  end

  defp parse_players(%{"info" => %{"participants" => participants}}) do
    {:ok,
      participants
        |> Enum.map(fn(participant) -> parse_player(participant) end)
    }
  end

  defp parse_players(_) do
    {:error, :invalid_data_structure}
  end

  defp parse_player(%{"puuid" => puuid, "summonerName" => name}) do
    %Summoner{
      name: name,
      puuid: puuid,
    }
  end

  defp parse_player(_) do
    {:error, :invalid_data_structure}
  end
end
