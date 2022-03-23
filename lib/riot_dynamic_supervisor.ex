defmodule Riot.DynamicSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  @spec init(any) ::
          {:ok,
           %{
             extra_arguments: list,
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_riot_system(String.t(), String.t(), String.t()) :: :ok | DynamicSupervisor.on_start_child()
  def start_riot_system(summoner_name, puuid, platform) do
    server =
      summoner_name
        |> RiotServer.server_name()
        |> GenServer.whereis()

    if server == nil do
      DynamicSupervisor.start_child(
        __MODULE__,
        {RiotServer, {summoner_name, puuid, platform}}
      )
    end
  end
end
