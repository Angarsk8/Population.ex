defmodule Population.Country do

  @moduledoc """
  This module defines functions to list all the countries in the world.

  See more in [api.population.io/countries](http://api.population.io/#!/countries)
  """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  @type failure   :: Population.CommonTypes.failure
  @type country   :: String.t
  @type countries :: [country]

  # Client API

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Retrieves a list of all countries in the statistical dataset.

  Returns `{:ok, countries}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Country.list
      {:ok, ["Afghanistan", "Albania", "Algeria", ...]}

  """
  @spec list() :: {:ok, countries} | failure
  def list do
    result = GenServer.call(__MODULE__, :get_countries)
    case result do
      {:ok, %{countries: countries}} ->
        {:ok, countries}
      _ ->
      result
    end
  end

  @doc """
  Retrieves a list of all countries in the statistical dataset.

  Returns `countries` if the call succeed, otherwise raises a `RuntimeError`
  with a message including the `reason`.

  ## Examples

      iex> Population.Country.list!
      ["Afghanistan", "Albania", "Algeria", ...]

  """
  @spec list!() :: countries | no_return
  def list! do
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
