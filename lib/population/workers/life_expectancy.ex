defmodule Population.LifeExpectancy do

  use GenServer
  use Population.Types

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat,
    only: [format_date: 1, format_date_offset: 1]

  import Population.Helpers.URIFormat, only: [encode_country: 1]

  # Client API

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec remaining(gender, country, date, offset) :: implicit_response
  def remaining(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining, gender, country, date, age})
  end

  @spec remaining!(gender, country, date, offset) :: explicit_response
  def remaining!(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining!, gender, country, date, age})
  end

  @spec total(gender, country, date) :: implicit_response
  def total(gender, country, dob) do
    GenServer.call(__MODULE__, {:get_total, gender, country, dob})
  end

  @spec total!(gender, country, date) :: explicit_response
  def total!(gender, country, dob) do
    GenServer.call(__MODULE__, {:get_total!, gender, country, dob})
  end

  # GenServer CallBacks

  def handle_call({:get_remaining, gender, country, date, age}, _from, state) do
    url_path_for_remaining(gender, country, date, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_remaining!, gender, country, date, age}, _from, _state) do
    url_path_for_remaining(gender, country, date, age)
    |> fetch_data
    |> handle_reply!
  end
  def handle_call({:get_total, gender, country, dob}, _from, state) do
    url_path_for_total(gender, country, dob)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_total!, gender, country, dob}, _from, _state) do
    url_path_for_total(gender, country, dob)
    |> fetch_data
    |> handle_reply!
  end

  # Helper Functions

  @spec url_path_for_remaining(gender, country, date, offset) :: String.t
  defp url_path_for_remaining(gender, country, date, age) do
    "life-expectancy/remaining/#{gender}/#{encode_country(country)}/#{format_date(date)}/#{format_date_offset(age)}/"
  end

  @spec url_path_for_total(gender, country, date) :: String.t
  defp url_path_for_total(gender, country, dob) do
    "life-expectancy/total/#{gender}/#{encode_country(country)}/#{format_date(dob)}/"
  end
end
