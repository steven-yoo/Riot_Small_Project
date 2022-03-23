defmodule Riot.RiotAPI.APIHelper do
  require Logger

  @platform_region_map %{
    "BR1" => "americas",
    "EUN1" => "europe",
    "EUW2" => "europe",
    "JP1" => "asia",
    "KR" => "asia",
    "LA1" => "americas",
    "LA2" => "americas",
    "NA1" => "americas",
    "OC1" => "asia",
    "RU" => "europe",
    "TR1" => "europe",
  }

  @doc """
  Returns the region based on the configured platform for summoner

  ## Examples
    iex> Riot.RiotAPI.APIHelper.get_region_by_platform("NA1")
    "americas"
  """
  @spec get_region_by_platform(String.t()) :: String.t()
  def get_region_by_platform(platform) do
    Map.fetch!(@platform_region_map, platform)
  end

  @doc """
  Returns the base riot api based on region

  ## Examples
    iex> Riot.RiotAPI.APIHelper.get_base_region_url("americas")
    "https://americas.api.riotgames.com/lol/"
  """
  @spec get_base_region_url(String.t()) :: String.t()
  def get_base_region_url(region) do
    "https://#{region}.api.riotgames.com/lol/"
  end

  @doc """
  Returns the region based on the configured platform for summoner

  ## Examples
    iex> Riot.RiotAPI.APIHelper.get_base_platform_url("NA1")
    "https://NA1.api.riotgames.com/lol/"
  """
  @spec get_base_platform_url(String.t()) :: String.t()
  def get_base_platform_url(platform) do
    "https://#{platform}.api.riotgames.com/lol/"
  end

  def send_get_request(url) do
    {_, x_riot_token} = Application.fetch_env(:riot, :x_riot_token)

    headers = [
      "X-Riot-Token": x_riot_token
    ]

    case HTTPoison.get(url, headers) |> check_response do
      {:ok, response} ->
        {:ok, response}
      {:error, :bad_request} ->
        IO.puts("Bad Riot API Request")
        {:error, :bad_request}
      {:error, response} ->
        IO.puts("Riot API Request Error: #{inspect(response)}")
        {:error, response}
    end
  end


  defp check_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode
  end

  defp check_response({:ok, %HTTPoison.Response{body: body, status_code: _}}) do
    {:ok, response} = body
      |> Poison.decode

    {:error, response}
  end

  defp check_response({:error, %HTTPoison.Error{reason: reason}}) do
    reason |> IO.inspect(pretty: true, label: "Bad Response")
    {:error, :bad_request}
  end
end
