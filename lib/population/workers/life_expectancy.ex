defmodule Population.LifeExpectancy do

  @moduledoc """
  This module defines functions to get data about the life expectancy of a
  person, given some information such as `gender`, `country`, `date` and `age`.

  See more in [api.population.io/life-expectancy](http://api.population.io/#!/life-expectancy)
  """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.CommonTypes.failure
  @type gender  :: Population.CommonTypes.gender
  @type offset  :: Population.CommonTypes.offset

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

  @doc """
  Calculates the remaining life expectancy of a person with given sex, country,
  and age at a given point in time.

  Returns `{:ok, remaining_life}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.LifeExpectancy.remaining(:male, "Colombia", ~D[2016-12-10], {24, 5})
      {:ok,
       %{age: "24y5m0d", country: "Colombia", date: "2016-12-10",
         remaining_life_expectancy: 54.63260155466486, sex: :male}}
      iex> Population.LifeExpectancy.remaining(:random, "Colombia", ~D[2016-12-10], {24, 5})
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec remaining(gender, String.t, Date.t, offset) :: {:ok, remaining_life} | failure
  def remaining(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining, gender, country, date, age})
  end

  @doc """
  Calculates the remaining life expectancy of a person with given sex, country,
  and age at a given point in time.

  Returns `remaining_life` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.LifeExpectancy.remaining!(:male, "Colombia", ~D[2016-12-10], {24, 5})
      %{age: "24y5m0d", country: "Colombia", date: "2016-12-10",
        remaining_life_expectancy: 54.63260155466486, sex: :male}
      iex> Population.LifeExpectancy.remaining!(:random, "Colombia", ~D[2016-12-10], {24, 5})
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec remaining!(gender, String.t, Date.t, offset) :: remaining_life | no_return
  def remaining!(gender, country, date, age) do
    GenServer.call(__MODULE__, {:get_remaining!, gender, country, date, age})
  end

  @doc """
  Calculates the total life expectancy of a person with given sex, country, and date
  of birth.

  Returns `{:ok, total_life}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.LifeExpectancy.total(:male, "Colombia", ~D[1992-06-21])
      {:ok,
       %{country: "Colombia", dob: "1992-06-21", sex: :male,
         total_life_expectancy: 80.89666673632185}}
      iex> Population.LifeExpectancy.total(:random, "Colombia", ~D[1992-06-21])
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec total(gender, String.t, Date.t) :: {:ok, total_life} | failure
  def total(gender, country, dob) do
    GenServer.call(__MODULE__, {:get_total, gender, country, dob})
  end

  @doc """
  Calculates the total life expectancy of a person with given sex, country, and date
  of birth.

  Returns `total_life` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.LifeExpectancy.total!(:male, "Colombia", ~D[1992-06-21])
      %{country: "Colombia", dob: "1992-06-21", sex: :male,
        total_life_expectancy: 80.89666673632185}
      iex> Population.LifeExpectancy.total!(:male, "Westeros", ~D[1992-06-21])
      ** (RuntimeError) Westeros is an invalid value for the parameter "country", the list of valid values can be retrieved from the endpoint /countries

  """
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
