defmodule Population.Country do

  use GenServer

  # CLIENT API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_countries do
    GenServer.call(__MODULE__, {:get_countries, opts})
  end

  # GENSERVER CALLBACKS

  def handle_call(:get_countries, _from, state) do
    case list_of_countries do
      {:ok, countries} ->
        {:reply, countries, countries}
      :error ->
        {:reply, :error, state}
    end
  end

  @api_url Application.get_env(:population, :api_url)
  @endpoint_path "/countries"

  defp list_of_countries do
    @endpoint_path
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end

  defp url_for(endpoint_path) do
    "#{@api_url}#{endpoint_path}"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    json = JSON.decode!(body)
    {:ok, json["countries"]}
  end
  defp handle_response(_) do
    :error
  end
end
