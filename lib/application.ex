defmodule  Riot.Application do
  use Application
  require Logger

  alias Riot.RiotAPI

  def start(_type, _args) do


    children = [
      {Riot.DynamicSupervisor, name: Riot.DynamicSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Riot.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    {:ok, summoner_name} = Application.fetch_env(:riot, :summoner_name)
    {:ok, platform} = Application.fetch_env(:riot, :platform)
    start_application(summoner_name, platform)

    {:ok, pid}
  end

  @doc """
  Gets summoner information and
  then starts up monitoring for new matches every minute for the next hour
  Will also monitor the last people played last 2 matches
  """
  @spec start_application(String.t(), String.t()) :: :ok
  def start_application(name, platform) do
    region = RiotAPI.get_region_by_platform(platform)

    with {:ok, summoner} <- RiotAPI.get_summoner_info(name, platform),
         {:ok, matches} <- RiotAPI.get_matches(summoner.puuid, region) do


      summoners = matches
        |> Enum.reduce([], fn match_id, summoners ->
          case RiotAPI.get_participants_from_match(match_id, region) do
            {:ok, players} ->
              [players | summoners]
            _ ->
              summoners
          end
        end)

      summoners = summoners
        |> Enum.concat
        |> Enum.uniq

      summoners
        |> Enum.each(&(Riot.DynamicSupervisor.start_riot_system(&1.name, &1.puuid, platform)))

      summoners = summoners
        |> Enum.map(&(&1.name))
        |> Enum.join(", ")

      IO.puts("[#{summoners}]")
    else
      _ -> IO.puts("unexpected errors")
    end
  end
end
