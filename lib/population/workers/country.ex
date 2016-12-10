defmodule Population.Country do

  use GenServer
  use Population.Types

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec list() :: implicit_response
  def list do
    result = GenServer.call(__MODULE__, :get_countries)
    case result do
      {:ok, %{"countries" => countries}} ->
        {:ok, countries}
      _ ->
      result
    end
  end

  @spec list!() :: explicit_response
  def list! do
    %{"countries" => countries} = GenServer.call(__MODULE__, :get_countries!)
    countries
  end

  # GenServer CallBacks

  def handle_call(:get_countries, _from, state) do
    fetch_data("countries")
    |> handle_reply(state)
  end
  def handle_call(:get_countries!, _from, _state) do
    fetch_data("countries")
    |> handle_reply!
  end
end
