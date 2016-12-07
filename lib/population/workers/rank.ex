defmodule Population.Rank do

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat,
    only: [format_date: 1, format_date_offset: 1]

  import Population.Helpers.URIFormat, only: [encode_country: 1]

  @typep gender :: Population.Types.gender
  @typep date   :: Population.Types.date
  @typep offset :: Population.Types.offset

  @typep implicit_response :: Population.Types.implicit_response
  @typep explicit_response :: Population.Types.explicit_response

  # Client API

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec today(date, gender, String.t) :: implicit_response
  def today(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today, dob, gender, country})
  end

  @spec today!(date, gender, String.t) :: explicit_response
  def today!(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today!, dob, gender, country})
  end

  @spec by_date(date, gender, String.t, date) :: implicit_response
  def by_date(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date, dob, gender, country, date})
  end

  @spec by_date!(date, gender, String.t, date) :: explicit_response
  def by_date!(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date!, dob, gender, country, date})
  end

  @spec by_age(date, gender, String.t, offset) :: implicit_response
  def by_age(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age, dob, gender, country, age})
  end

  @spec by_age!(date, gender, String.t, offset) :: explicit_response
  def by_age!(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age!, dob, gender, country, age})
  end

  @spec in_past(date, gender, String.t, offset) :: implicit_response
  def in_past(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past, dob, gender, country, ago})
  end

  @spec in_past!(date, gender, String.t, offset) :: explicit_response
  def in_past!(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past!, dob, gender, country, ago})
  end

  @spec in_future(date, gender, String.t, offset) :: implicit_response
  def in_future(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future, dob, gender, country, future_date})
  end

  @spec in_future!(date, gender, String.t, offset) :: explicit_response
  def in_future!(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future!, dob, gender, country, future_date})
  end

  @spec date_by_rank(date, gender, String.t, integer) :: implicit_response
  def date_by_rank(dob, gender, country, rank) do
    GenServer.call(__MODULE__, {:get_date_by_rank, dob, gender, country, rank})
  end

  @spec date_by_rank!(date, gender, String.t, integer) :: explicit_response
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

  @spec url_path_for_today(date, gender, String.t) :: String.t
  defp url_path_for_today(dob, gender, country) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/today/"
  end

  @spec url_path_by_date(date, gender, String.t, date) :: String.t
  defp url_path_by_date(dob, gender, country, date) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/on/#{format_date(date)}/"
  end

  @spec url_path_by_age(date, gender, String.t, offset) :: String.t
  defp url_path_by_age(dob, gender, country, age) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/aged/#{format_date_offset(age)}/"
  end

  @spec url_path_in_past(date, gender, String.t, offset) :: String.t
  defp url_path_in_past(dob, gender, country, ago) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/ago/#{format_date_offset(ago)}/"
  end

  @spec url_path_in_future(date, gender, String.t, offset) :: String.t
  defp url_path_in_future(dob, gender, country, future) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/in/#{format_date_offset(future)}/"
  end

  @spec url_path_for_date_by_rank(date, gender, String.t, integer) :: String.t
  defp url_path_for_date_by_rank(dob, gender, country, rank) do
    "wp-rank/#{format_date(dob)}/#{gender}/#{encode_country(country)}/ranked/#{rank}/"
  end
end
