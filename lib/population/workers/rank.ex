defmodule Population.Rank do

  use GenServer
  use Population.Types

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  # Client API

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec today(date, wgender, country) :: {:ok, rank_today} | failure
  def today(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today, dob, gender, country})
  end

  @spec today!(date, wgender, country) :: rank_today | no_return
  def today!(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today!, dob, gender, country})
  end

  @spec by_date(date, wgender, country, date) :: {:ok, rank_by_date} | failure
  def by_date(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date, dob, gender, country, date})
  end

  @spec by_date!(date, wgender, country, date) :: rank_by_date | no_return
  def by_date!(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date!, dob, gender, country, date})
  end

  @spec by_age(date, wgender, country, offset) :: {:ok, rank_by_age} | failure
  def by_age(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age, dob, gender, country, age})
  end

  @spec by_age!(date, wgender, country, offset) :: rank_by_age | no_return
  def by_age!(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age!, dob, gender, country, age})
  end

  @spec in_past(date, wgender, country, offset) :: {:ok, rank_with_offset} | failure
  def in_past(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past, dob, gender, country, ago})
  end

  @spec in_past!(date, wgender, country, offset) :: rank_with_offset | no_return
  def in_past!(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past!, dob, gender, country, ago})
  end

  @spec in_future(date, wgender, country, offset) :: {:ok, rank_with_offset} | failure
  def in_future(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future, dob, gender, country, future_date})
  end

  @spec in_future!(date, wgender, country, offset) :: rank_with_offset | no_return
  def in_future!(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future!, dob, gender, country, future_date})
  end

  @spec date_by_rank(date, wgender, country, integer) :: {:ok, date_by_rank} | failure
  def date_by_rank(dob, gender, country, rank) do
    GenServer.call(__MODULE__, {:get_date_by_rank, dob, gender, country, rank})
  end

  @spec date_by_rank!(date, wgender, country, integer) :: date_by_rank | no_return
  def date_by_rank!(dob, gender, country, rank) do
    GenServer.call(__MODULE__, {:get_date_by_rank!, dob, gender, country, rank})
  end

  # GenServer CallBacks

  def handle_call({:get_rank_today, dob, gender, country}, _from, state) do
    url_path_for_today(dob, gender, country)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_rank_today!, dob, gender, country}, _from, _state) do
    url_path_for_today(dob, gender, country)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_rank_by_date, dob, gender, country, date}, _from, state) do
    url_path_by_date(dob, gender, country, date)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_rank_by_date!, dob, gender, country, date}, _from, _state) do
    url_path_by_date(dob, gender, country, date)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_rank_by_age, dob, gender, country, age}, _from, state) do
    url_path_by_age(dob, gender, country, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_rank_by_age!, dob, gender, country, age}, _from, _state) do
    url_path_by_age(dob, gender, country, age)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_rank_in_past, dob, gender, country, ago}, _from, state) do
    url_path_in_past(dob, gender, country, ago)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_rank_in_past!, dob, gender, country, ago}, _from, _state) do
    url_path_in_past(dob, gender, country, ago)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_rank_in_future, dob, gender, country, future}, _from, state) do
    url_path_in_future(dob, gender, country, future)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_rank_in_future!, dob, gender, country, future}, _from, _state) do
    url_path_in_future(dob, gender, country, future)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_date_by_rank, dob, gender, country, rank}, _from, state) do
    url_path_for_date_by_rank(dob, gender, country, rank)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_date_by_rank!, dob, gender, country, rank}, _from, _state) do
    url_path_for_date_by_rank(dob, gender, country, rank)
    |> fetch_data
    |> handle_reply!
  end

  # Helper Functions

  @spec url_path_for_today(date, wgender, country) :: String.t
  defp url_path_for_today(dob, gender, country) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/today/"
  end

  @spec url_path_by_date(date, wgender, country, date) :: String.t
  defp url_path_by_date(dob, gender, country, date) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/on/#{Date.to_string(date)}/"
  end

  @spec url_path_by_age(date, wgender, country, offset) :: String.t
  defp url_path_by_age(dob, gender, country, age) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/aged/#{format_date_offset(age)}/"
  end

  @spec url_path_in_past(date, wgender, country, offset) :: String.t
  defp url_path_in_past(dob, gender, country, ago) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/ago/#{format_date_offset(ago)}/"
  end

  @spec url_path_in_future(date, wgender, country, offset) :: String.t
  defp url_path_in_future(dob, gender, country, future) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/in/#{format_date_offset(future)}/"
  end

  @spec url_path_for_date_by_rank(date, wgender, country, integer) :: String.t
  defp url_path_for_date_by_rank(dob, gender, country, rank) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/ranked/#{rank}/"
  end
end
