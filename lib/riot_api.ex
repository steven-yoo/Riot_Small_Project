defmodule Riot.RiotAPI do
  require Logger

  alias Riot.RiotAPI.Summoner
  alias Riot.RiotAPI.Match

  @spec get_summoner_info(String.t(), String.t()) :: Summoner.maybe_summoner()
  def get_summoner_info(summoner_name, platform) do
    Summoner.get_summoner_info(summoner_name, platform)
  end

  @spec get_matches(String.t(), String.t()) :: Match.maybe_matches()
  def get_matches(puuid, region) do
    Match.get_matches(puuid, region)
  end

  @spec get_last_matches(String.t(), String.t(), integer()) :: Match.maybe_matches()
  def get_last_matches(puuid, region, timestamp) do
    Match.get_last_matches(puuid, region, timestamp)
  end

  @spec get_participants_from_match(String.t(), String.t()) :: Match.maybe_participants()
  def get_participants_from_match(match_id, region) do
    Match.get_players_from_match(match_id, region)
  end

  @spec get_region_by_platform(String.t()) :: String.t()
  def get_region_by_platform(platform) do
    Riot.RiotAPI.APIHelper.get_region_by_platform(platform)
  end
end
