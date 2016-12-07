defmodule Population.Country do

  use GenServer

  import Population.API

  @typep countries :: Population.Types.countries

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec list() :: {:ok, countries} | {:error, String.t}
  def list do
    GenServer.call(__MODULE__, :get_countries)
  end

  @spec list!() :: countries | no_return
  def list! do
    GenServer.call(__MODULE__, :get_countries!)
  end

  # GenServer CallBacks

  def handle_call(:get_countries, _from, state) do
    case fetch_data("countries") do
      {:ok, json_resp} ->
        {:reply, {:ok, json_resp["countries"]}, json_resp["countries"]}
      error ->
        {:reply, error, state}
    end
  end
  def handle_call(:get_countries!, _from, _state) do
    case fetch_data("countries") do
      {:ok, json_resp} ->
        {:reply, json_resp["countries"], json_resp["countries"]}
      {:error, reason} ->
        raise reason
    end
  end
end
