defmodule Population.Table do

  @moduledoc """
  This module defines functions to get data related to the world population
  tables, given some information such as `country`, `year`, `age`, etc.

  See more in (api.population.io/population)[http://api.population.io/#!/population]
  """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.CommonTypes.failure
  @type gender  :: Population.CommonTypes.gender
  @type offset  :: Population.CommonTypes.offset
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

  @doc """
  Retrieves the population table for all countries and a specific age group in
  the given year.

  Returns `{:ok, population_tables}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.all(2014, 18)
      {:ok,
       [%{age: 18, country: "Afghanistan", females: 350820, males: 366763,
          total: 717583, year: 2014},
        %{age: 18, country: "Albania", females: 29633, males: 30478, total: 60111,
          year: 2014},
        ...]}
      iex> Population.Table.all(2500, 18)
      {:error,
       "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

  """
  @spec all(year, age) :: {:ok, population_tables} | failure
  def all(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables, year, age})
  end

  @doc """
  Retrieves the population table for all countries and a specific age group in
  the given year.

  Returns `population_tables` if the call succeed, otherwise raises a
  `RuntimeError` with a message including the `reason`.

  ## Examples

      iex> Population.Table.all!(2014, 18)
      [%{age: 18, country: "Afghanistan", females: 350820, males: 366763,
         total: 717583, year: 2014},
       %{age: 18, country: "Albania", females: 29633, males: 30478, total: 60111,
         year: 2014},
       ...]
      iex> Population.Table.all!(2500, 18)
      ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

  """
  @spec all!(year, age) :: population_tables | no_return
  def all!(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables!, year, age})
  end

  @doc """
  Retrieves the population table for a specific age group in the given year and
  country.

  Returns `{:ok, population_table}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.by_country("Colombia", 2014, 18)
      {:ok,
       %{age: 18, country: "Colombia", females: 430971, males: 445096, total: 876067,
         year: 2014}}
      iex> Population.Table.by_country("Colombia", 2500, 18)
      {:error,
       "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

  """
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

  @doc """
  Retrieves the population table for a specific age group in the given year and
  country.

  Returns `population_table` if the call succeed, otherwise raises a
  `RuntimeError` with a message including the `reason`.

  ## Examples

      iex> Population.Table.by_country!("Colombia", 2014, 18)
      %{age: 18, country: "Colombia", females: 430971, males: 445096, total: 876067,
        year: 2014}
      iex> Population.Table.by_country!("Colombia", 2500, 18)
      ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

  """
  @spec by_country!(String.t, year, age) :: population_table | no_return
  def by_country!(country, year, age) do
    [table | _] = GenServer.call(__MODULE__, {:get_table_by_country!, country, year, age})
    table
  end

  @doc """
  Retrieves the population tables for a given year and country. Returns tables
  for all ages from `0` to `100`.

  Returns `{:ok, population_tables}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.all_ages_by_country("Colombia", 2014)
      {:ok,
       [%{age: 0, country: "Colombia", females: 432462, males: 452137, total: 884599,
          year: 2014},
        %{age: 1, country: "Colombia", females: 436180, males: 455621, total: 891802,
          year: 2014},
        ...]}
      iex> Population.Table.all_ages_by_country("Colombia", 2500)
      {:error,
       "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

  """
  @spec all_ages_by_country(String.t, year) :: {:ok, population_tables} | failure
  def all_ages_by_country(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country, country, year})
  end

  @doc """
  Retrieves the population tables for a given year and country. Returns tables
  for all ages from `0` to `100`.

  Returns `population_tables` if the call succeed, otherwise raises a
  `RuntimeError` with a message including the `reason`.

  ## Examples

      iex> Population.Table.all_ages_by_country!("Colombia", 2014)
      [%{age: 0, country: "Colombia", females: 432462, males: 452137, total: 884599,
         year: 2014},
       %{age: 1, country: "Colombia", females: 436180, males: 455621, total: 891802,
         year: 2014},
       ...]
      iex> Population.Table.all_ages_by_country!("Colombia", 2500)
      ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

  """
  @spec all_ages_by_country!(String.t, year) :: population_tables | no_return
  def all_ages_by_country!(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country!, country, year})
  end

  @doc """
  Retrieves the population tables for a specific age group in the given country.
  Returns tables for all years from `1950` to `2100`.

  Returns `{:ok, population_tables}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.all_years_by_country("Colombia", 18)
      {:ok,
       [%{age: 18, country: "Colombia", females: 114873, males: 116249, total: 231122,
          year: 1950},
        %{age: 18, country: "Colombia", females: 116899, males: 118123, total: 235022,
          year: 1951},
        ...]}
      iex> Population.Table.all_years_by_country("Colombia", 101)
      {:error,
       "The age 101 can not be processed, because only ages between 0 and 100 years are supported"}

  """
  @spec all_years_by_country(String.t, age) :: {:ok, population_tables} | failure
  def all_years_by_country(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country, country, age})
  end

  @doc """
  Retrieves the population tables for a specific age group in the given country.
  Returns tables for all years from `1950` to `2100`.

  Returns `population_tables` if the call succeed, otherwise raises a
  `RuntimeError` with a message including the `reason`.

  ## Examples

      iex> Population.Table.all_years_by_country!("Colombia", 18)
      [%{age: 18, country: "Colombia", females: 114873, males: 116249, total: 231122,
         year: 1950},
       %{age: 18, country: "Colombia", females: 116899, males: 118123, total: 235022,
         year: 1951},
       ...]
      iex> Population.Table.all_years_by_country!("Colombia", 101)
      ** (RuntimeError) The age 101 can not be processed, because only ages between 0 and 100 years are supported

  """
  @spec all_years_by_country!(String.t, age) :: population_tables | no_return
  def all_years_by_country!(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country!, country, age})
  end

  @doc """
  Determines total population for a given country on a given date.
  Valid dates are `2013-01-01` to `2022-12-31`.

  Returns `{:ok, total_population}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.for_country_by_date("Colombia", ~D[2016-12-10])
      {:ok, %{date: "2016-12-10", population: 50377885}}
      iex> Population.Table.for_country_by_date("Colombia", ~D[2012-12-10])
      {:error,
       "The calculation date 2012-12-10 can not be processed, only dates between 2013-01-01 and 2022-12-31 are supported"}

  """
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

  @doc """
  Determines total population for a given country on a given date.
  Valid dates are `2013-01-01` to `2022-12-31`.

  Returns `total_population` if the call succeed, otherwise raises a
  `RuntimeError` with a message including the `reason`.

  ## Examples

      iex> Population.Table.for_country_by_date!("Colombia", ~D[2016-12-10])
      %{date: "2016-12-10", population: 50377885}
      iex> Population.Table.for_country_by_date!("Colombia", ~D[2012-12-10])
      ** (RuntimeError) The calculation date 2012-12-10 can not be processed, only dates between 2013-01-01 and 2022-12-31 are supported

  """
  @spec for_country_by_date!(String.t, Date.t) :: population_table | no_return
  def for_country_by_date!(country, date) do
    %{total_population: total} = GenServer.call(__MODULE__, {:get_table_for_country_by_date!, country, date})
    total
  end

  @doc """
  Determines total population for a given country with separate results for
  `today` and `tomorrow`.

  Returns `{:ok, %{today: total_population, tomorrow: total_population}}` if the
  call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Table.for_today_and_tomorrow_by_country("Colombia")
      {:ok,
       %{today: %{date: "2016-12-11", population: 50379477},
         tomorrow: %{date: "2016-12-12", population: 50381070}}}
      iex> Population.Table.for_today_and_tomorrow_by_country("Pluton")
      {:error,
       "Pluton is an invalid value for the parameter \"country\", the list of valid values can be retrieved from the endpoint /countries"}

  """
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

  @doc """
  Determines total population for a given country with separate results for
  `today` and `tomorrow`.

  Returns `%{today: total_population, tomorrow: total_population}` if the call
  succeed, otherwise raises a `RuntimeError` with a message including the
  `reason`.

  ## Examples

      iex> Population.Table.for_today_and_tomorrow_by_country!("Colombia")
      %{today: %{date: "2016-12-11", population: 50379477},
        tomorrow: %{date: "2016-12-12", population: 50381070}}
      iex> Population.Table.for_today_and_tomorrow_by_country!("Pluton")
      ** (RuntimeError) Pluton is an invalid value for the parameter "country", the list of valid values can be retrieved from the endpoint /countries

  """
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
