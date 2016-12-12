defmodule Population.Table do

  @moduledoc false

  # """
  # This module defines functions to get data related to the world population
  # tables, given some information such as `country`, `year`, `age`, etc.
  #
  # See more in (api.population.io/population)[http://api.population.io/#!/population]
  # """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.Types.failure
  @type gender  :: Population.Types.gender
  @type offset  :: Population.Types.offset
  @type year    :: 1950..2100
  @type age     :: 0..100

  @type population_table :: %{
    total: integer,
    females: integer,
    males: integer,
    year: year,
    age: age
  }

  @type population_tables :: [population_table]

  @type total_population :: %{
    date: String.t,
    population: integer
  }

  @type population_contrast :: %{
    today: total_population,
    tomorrow: total_population
  }

  # Client API

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec all(year, age) :: {:ok, population_tables} | failure
  def all(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables, year, age})
  end

  @spec all!(year, age) :: population_tables | no_return
  def all!(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables!, year, age})
  end

  @spec by_country(String.t, year, age) :: {:ok, population_table} | failure
  def by_country(country, year, age) do
    result = GenServer.call(__MODULE__, {:get_table_by_country, country, year, age})
    case result do
      {:ok, [table | _]} ->
        {:ok, table}
      _ ->
        result
    end
  end

  @spec by_country!(String.t, year, age) :: population_table | no_return
  def by_country!(country, year, age) do
    [table | _] = GenServer.call(__MODULE__, {:get_table_by_country!, country, year, age})
    table
  end

  @spec all_ages_by_country(String.t, year) :: {:ok, population_tables} | failure
  def all_ages_by_country(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country, country, year})
  end

  @spec all_ages_by_country!(String.t, year) :: population_tables | no_return
  def all_ages_by_country!(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country!, country, year})
  end

  @spec all_years_by_country(String.t, age) :: {:ok, population_tables} | failure
  def all_years_by_country(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country, country, age})
  end

  @spec all_years_by_country!(String.t, age) :: population_tables | no_return
  def all_years_by_country!(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country!, country, age})
  end

  @spec for_country_by_date(String.t, Date.t) :: {:ok, population_table} | failure
  def for_country_by_date(country, date) do
    result = GenServer.call(__MODULE__, {:get_table_for_country_by_date, country, date})
    case result do
      {:ok, %{ total_population: total}} ->
        {:ok, total}
      _ ->
        result
    end
  end

  @spec for_country_by_date!(String.t, Date.t) :: population_table | no_return
  def for_country_by_date!(country, date) do
    %{total_population: total} = GenServer.call(__MODULE__, {:get_table_for_country_by_date!, country, date})
    total
  end

  @spec for_today_and_tomorrow_by_country(String.t) :: {:ok, population_contrast} | failure
  def for_today_and_tomorrow_by_country(country) do
    result = GenServer.call(__MODULE__, {:get_table_for_today_and_tomorrow_by_country, country})
    case result do
      {:ok, %{total_population: [today, tomorrow | _]}} ->
        {:ok, %{today: today, tomorrow: tomorrow}}
      _ ->
      result
    end
  end

  @spec for_today_and_tomorrow_by_country!(String.t) ::  population_contrast | no_return
  def for_today_and_tomorrow_by_country!(country) do
    %{total_population: [today, tomorrow | _]} = GenServer.call(__MODULE__, {:get_table_for_today_and_tomorrow_by_country!, country})
    %{today: today, tomorrow: tomorrow}
  end

  # GenServer CallBacks

  def handle_call({:get_all_tables, year, age}, _from, state) do
    url_path_for_all_countries(year, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_all_tables!, year, age}, _from, _state) do
    url_path_for_all_countries(year, age)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_table_by_country, country, year, age}, _from, state) do
    url_path_by_country(country, year, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_table_by_country!, country, year, age}, _from, _state) do
    url_path_by_country(country, year, age)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_tables_for_all_ages_by_country, country, year}, _from, state) do
    url_path_for_all_ages_by_country(country, year)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_tables_for_all_ages_by_country!, country, year}, _from, _state) do
    url_path_for_all_ages_by_country(country, year)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_tables_for_all_years_by_country, country, age}, _from, state) do
    url_path_for_all_years_by_country(country, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_tables_for_all_years_by_country!, country, age}, _from, _state) do
    url_path_for_all_years_by_country(country, age)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_table_for_country_by_date, country, date}, _from, state) do
    url_path_for_country_by_date(country, date)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_table_for_country_by_date!, country, date}, _from, _state) do
    url_path_for_country_by_date(country, date)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_table_for_today_and_tomorrow_by_country, country}, _from, state) do
    url_path_for_today_and_tomorrow_by_country(country)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_table_for_today_and_tomorrow_by_country!, country}, _from, _state) do
    url_path_for_today_and_tomorrow_by_country(country)
    |> fetch_data
    |> handle_reply!
  end

  # Helper Functions

  defp url_path_for_all_countries(year, age) do
    "population/#{year}/aged/#{age}/"
  end

  defp url_path_by_country(country, year, age) do
    "population/#{year}/#{encode_country(country)}/#{age}/"
  end

  defp url_path_for_all_ages_by_country(country, year) do
    "population/#{year}/#{encode_country(country)}/"
  end

  defp url_path_for_all_years_by_country(country, age) do
    "population/#{encode_country(country)}/#{age}/"
  end

  defp url_path_for_country_by_date(country, date) do
    "population/#{encode_country(country)}/#{Date.to_string(date)}/"
  end

  defp url_path_for_today_and_tomorrow_by_country(country) do
    "population/#{encode_country(country)}/today-and-tomorrow/"
  end
end
