defmodule Population.Table do

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @typep country :: Population.Types.country
  @typep year    :: Population.Types.year
  @typep age     :: Population.Types.age
  @typep date    :: Population.Types.date

  @typep implicit_response :: Population.Types.implicit_response
  @typep explicit_response :: Population.Types.explicit_response

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec all(year, age) :: implicit_response
  def all(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables, year, age})
  end

  @spec all!(year, age) :: explicit_response
  def all!(year, age) do
    GenServer.call(__MODULE__, {:get_all_tables!, year, age})
  end

  @spec by_country(country, year, age) :: implicit_response
  def by_country(country, year, age) do
    result = GenServer.call(__MODULE__, {:get_table_by_country, country, year, age})
    case result do
      {:ok, [table | _]} ->
        {:ok, table}
      _ ->
        result
    end
  end

  @spec by_country!(country, year, age) :: explicit_response
  def by_country!(country, year, age) do
    [table | _] = GenServer.call(__MODULE__, {:get_table_by_country!, country, year, age})
    table
  end

  @spec all_ages_by_country(country, year) :: implicit_response
  def all_ages_by_country(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country, country, year})
  end

  @spec all_ages_by_country!(country, year) :: explicit_response
  def all_ages_by_country!(country, year) do
    GenServer.call(__MODULE__, {:get_tables_for_all_ages_by_country!, country, year})
  end

  @spec all_years_by_country(country, age) :: implicit_response
  def all_years_by_country(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country, country, age})
  end

  @spec all_years_by_country!(country, age) :: explicit_response
  def all_years_by_country!(country, age) do
    GenServer.call(__MODULE__, {:get_tables_for_all_years_by_country!, country, age})
  end

  @spec for_country_by_date(country, date) :: implicit_response
  def for_country_by_date(country, date) do
    result = GenServer.call(__MODULE__, {:get_table_for_country_by_date, country, date})
    case result do
      {:ok, %{ "total_population" => total}} ->
        {:ok, total}
      _ ->
        result
    end
  end

  @spec for_country_by_date!(country, date) :: explicit_response
  def for_country_by_date!(country, date) do
    %{"total_population" => total} = GenServer.call(__MODULE__, {:get_table_for_country_by_date!, country, date})
    total
  end

  @spec for_today_and_tomorrow_by_country(country) :: implicit_response
  def for_today_and_tomorrow_by_country(country) do
    result = GenServer.call(__MODULE__, {:get_table_for_today_and_tomorrow_by_country, country})
    case result do
      {:ok, %{"total_population" => [today, tomorrow | _]}} ->
        {:ok, {today, tomorrow}}
      _ ->
      result
    end
  end

  @spec for_today_and_tomorrow_by_country!(country) :: explicit_response
  def for_today_and_tomorrow_by_country!(country) do
    %{"total_population" => [today, tomorrow | _]} = GenServer.call(__MODULE__, {:get_table_for_today_and_tomorrow_by_country!, country})
    {today, tomorrow}
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

  @spec url_path_for_all_countries(year, age) :: String.t
  defp url_path_for_all_countries(year, age) do
    "population/#{year}/aged/#{age}/"
  end

  @spec url_path_by_country(country, year, age) :: String.t
  defp url_path_by_country(country, year, age) do
    "population/#{year}/#{encode_country(country)}/#{age}/"
  end

  @spec url_path_for_all_ages_by_country(country, year) :: String.t
  defp url_path_for_all_ages_by_country(country, year) do
    "population/#{year}/#{encode_country(country)}/"
  end

  @spec url_path_for_all_years_by_country(country, age) :: String.t
  defp url_path_for_all_years_by_country(country, age) do
    "population/#{encode_country(country)}/#{age}/"
  end

  @spec url_path_for_country_by_date(country, date) :: String.t
  defp url_path_for_country_by_date(country, date) do
    "population/#{encode_country(country)}/#{format_date(date)}/"
  end

  @spec url_path_for_today_and_tomorrow_by_country(country) :: String.t
  defp url_path_for_today_and_tomorrow_by_country(country) do
    "population/#{encode_country(country)}/today-and-tomorrow/"
  end
end
