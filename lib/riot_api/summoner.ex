defmodule Riot.RiotAPI.Summoner do
  require Logger

  alias Riot.RiotAPI.APIHelper

  defstruct [
    :name,
    :puuid,
  ]

  @type t :: %__MODULE__{
    name: String.t(),
    puuid: String.t(),
  }

  @type maybe_summoner ::
          {:ok, %{name: String.t(), puuid: String.t()}} | {:error, :failed_request}

  @spec get_summoner_info(String.t(), String.t()) :: maybe_summoner()
  def get_summoner_info(summoner_name, platform) do
    url = APIHelper.get_base_platform_url(platform) <> "summoner/v4/summoners/by-name/#{summoner_name}"

    with {:ok, response} <- Riot.RiotAPI.APIHelper.send_get_request(url),
         {:ok, summoner} <- convert_api_response_to_dto(response) do
      {:ok, summoner}
    else
      {:error, _} ->
        {:error, :failed_request}
    end
  end

  defp convert_api_response_to_dto(%{"puuid" => puuid, "name" => name}) do
    {:ok,
    %{
        name: name,
        puuid: puuid,
      }
    }
  end

  defp convert_api_response_to_dto(_) do
    {:error, :unexpected_data_structure}
  end
end
