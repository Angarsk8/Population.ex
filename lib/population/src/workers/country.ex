defmodule Population.Country do

  @moduledoc false

  # """
  # This module defines functions to list all the countries in the world.
  #
  # See more in [api.population.io/countries](http://api.population.io/#!/countries)
  # """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  @type failure   :: Population.Types.failure
  @type country   :: String.t
  @type countries :: [country]

  # Client API

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec list() :: {:ok, countries} | failure
  def list() do
    result = GenServer.call(__MODULE__, :get_countries)
    case result do
      {:ok, %{countries: countries}} ->
        {:ok, countries}
      _ ->
      result
    end
  end

  @spec list!() :: countries | no_return
  def list!() do
    %{countries: countries} = GenServer.call(__MODULE__, :get_countries!)
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
