defmodule RiotServer do
  use GenServer, restart: :temporary
  require Logger

  alias Riot.RiotAPI

  @moduledoc """
  Documentation for `Riot`.
  """

  @minute 1000 * 60
  @hour @minute * 60

  @type state :: %{
    last_match_check_time: number,
    region: String.t(),
    platform: String.t(),
    summoner: summoner()
  }

  @type summoner:: Riot.RiotAPI.Summoner.t()

  @spec server_name(String.t()) :: GenServer.name()
  def server_name(summoner_name) do
    {:global, "#{__MODULE__}.#{summoner_name}"}
  end

  @spec start_link({binary, any, any}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({summoner_name, puuid, platform}) do
    name = server_name(summoner_name)
    GenServer.start_link(__MODULE__,{summoner_name, puuid, platform}, name: name)
  end

  @impl true
  @spec init({any, any, binary}) ::
          {:ok,
           %{
             last_match_check_time: integer,
             platform: binary,
             region: <<_::32, _::_*16>>,
             summoner: %{puuid: any, summoner_name: any}
           }}
  def init({ summoner_name, puuid, platform}) do
    currentTimeStamp = DateTime.utc_now
      |> DateTime.to_unix(:second)

    state = %{
      last_match_check_time: currentTimeStamp,
      platform: platform,
      region: RiotAPI.get_region_by_platform(platform),
      summoner: %{
        summoner_name: summoner_name,
        puuid: puuid,
      }
    }

    send(self(), :after_init)

    {:ok, state}
  end

  @impl true
  def handle_info(:after_init, state) do
    Process.send_after(self(), :refresh_matches, @minute)
    Process.send_after(self(), :destroy_server, @hour)

    {:noreply, state}
  end

  @impl true
  def handle_info(:refresh_matches, state) do
    summoner_name = state
      |> Map.get(:summoner)
      |> Map.get(:summoner_name)

    check_time = state.last_match_check_time
    state = state
      |> Map.put(:last_match_check_time, DateTime.utc_now |> DateTime.to_unix(:second))

    case RiotAPI.get_last_matches(state.summoner.puuid, state.region, check_time) do
      {:ok, matches} ->
        matches
          |> Enum.each(fn(match_id) -> IO.puts("Summoner #{summoner_name} completed match #{match_id}") end)
      _ ->
        IO.puts("bad request")
    end


    Process.send_after(self(), :refresh_matches, @minute)

    {:noreply, state}
  end

  @impl true
  def handle_info(:destroy_server, state) do
    {:stop, :normal, state}
  end
end
