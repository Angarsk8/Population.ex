defmodule Population.LifeExpectancy do

  @moduledoc false

  # """
  # This module defines functions to get data about the life expectancy of a
  # person, given some information such as `gender`, `country`, `date` and `age`.
  #
  # See more in [api.population.io/life-expectancy](http://api.population.io/#!/life-expectancy)
  # """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.Types.failure
  @type gender  :: Population.Types.gender
  @type offset  :: Population.Types.offset

  @type remaining_life :: %{
    sex: gender,
    country: String.t,
    date: String.t,
    remaining_life_expectancy: float
  }

  @type total_life :: %{
    sex: gender,
    country: String.t,
    date: String.t,
    total_life_expectancy: float
  }

  # Client API

  @doc false
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec remaining(gender, String.t, Date.t, offset) :: {:ok, remaining_life} | failure
  def remaining(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining, gender, country, date, age})
  end

  @spec remaining!(gender, String.t, Date.t, offset) :: remaining_life | no_return
  def remaining!(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining!, gender, country, date, age})
  end

  @spec total(gender, String.t, Date.t) :: {:ok, total_life} | failure
  def total(gender, country, dob) do
    GenServer.call(__MODULE__, {:get_total, gender, country, dob})
  end

  @spec total!(gender, String.t, Date.t) :: total_life | no_return
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

  defp url_path_for_remaining(gender, country, date, age) do
    "life-expectancy/remaining/#{gender}/#{encode_country(country)}/#{Date.to_string(date)}/#{format_date_offset(age)}/"
  end

  defp url_path_for_total(gender, country, dob) do
    "life-expectancy/total/#{gender}/#{encode_country(country)}/#{Date.to_string(dob)}/"
  end
end
