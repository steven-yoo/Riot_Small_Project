defmodule RiotTest do
  use ExUnit.Case
  doctest Riot.RiotAPI.APIHelper

  alias Riot.RiotAPI.APIHelper

  @spec get_region_by_platform(String.t()) :: String.t()
  def get_region_by_platform(platform) do
    Map.fetch!(@platform_region_map, platform)
  end

  test "NA1 Correct Platform Map" do
    assert  APIHelper.get_region_by_platform("BR1") == "americas"
    assert  APIHelper.get_region_by_platform("KR") == "asia"
    assert  APIHelper.get_region_by_platform("NA1") == "americas"
    assert  APIHelper.get_region_by_platform("EUN1") == "europe"
  end
end
