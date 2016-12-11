defmodule Population.Rank do

  @moduledoc """
  This module defines functions to get the world population rank of a person,
  given some information such as `date-of-birth`, `gender`, `country`, etc.

  * The world population rank is defined as the position of someone's birthday
  among the group of living people of the same sex and country of origin,
  ordered by date of birth decreasing. The last person born is assigned rank #1.

  See more in [api.population.io/wp-rank](http://api.population.io/#!/wp-rank)
  """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.CommonTypes.failure
  @type gender  :: Population.CommonTypes.gender | :unisex
  @type offset  :: Population.CommonTypes.offset

  @type rank_today :: %{
    dob: String.t,
    sex: gender,
    country: String.t,
    rank: integer
  }

  @type rank_by_date :: %{
    dob: String.t,
    sex: gender,
    country: String.t,
    rank: integer,
    date: String.t
  }

  @type rank_by_age :: %{
    dob: String.t,
    sex: gender,
    country: String.t,
    rank: integer,
    age: String.t
  }

  @type rank_with_offset :: %{
    dob: String.t,
    sex: gender,
    country: String.t,
    rank: integer,
    offset: String.t
  }

  @type date_by_rank :: %{
    dob: String.t,
    sex: gender,
    country: String.t,
    rank: integer,
    date_on_rank: String.t
  }

  # Client API

  @doc false
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin as of today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `{:ok, rank_today}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.today(~D[1992-06-21], :unisex, "Colombia")
      {:ok, %{country: "Colombia", dob: "1992-06-21", rank: 21614190, sex: :unisex}}
      iex> Population.Rank.today(~D[1992-06-21], :random, "Colombia")
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec today(Date.t, gender, String.t) :: {:ok, rank_today} | failure
  def today(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today, dob, gender, country})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin as of today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `rank_today` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.Rank.today!(~D[1992-06-21], :unisex, "Colombia")
      %{country: "Colombia", dob: "1992-06-21", rank: 21614190, sex: :unisex}
      iex> Population.Rank.today!(~D[1992-06-21], :random, "Colombia")
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec today!(Date.t, gender, String.t) :: rank_today | no_return
  def today!(dob, gender, country) do
    GenServer.call(__MODULE__, {:get_rank_today!, dob, gender, country})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date.

  Returns `{:ok, rank_by_date}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.by_date(~D[1992-06-21], :unisex, "Colombia", ~D[2016-12-10])
      {:ok,
       %{country: "Colombia", date: "2016-12-10", dob: "1992-06-21", rank: 21611869,
         sex: :unisex}}
      iex> Population.Rank.by_date(~D[1992-06-21], :random, "Colombia", ~D[2016-12-10])
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec by_date(Date.t, gender, String.t, Date.t) :: {:ok, rank_by_date} | failure
  def by_date(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date, dob, gender, country, date})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date.

  Returns `rank_by_date` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.Rank.by_date!(~D[1992-06-21], :unisex, "Colombia", ~D[2016-12-10])
      %{country: "Colombia", date: "2016-12-10", dob: "1992-06-21", rank: 21611869,
        sex: :unisex}
      iex> Population.Rank.by_date!(~D[1992-06-21], :random, "Colombia", ~D[2016-12-10])
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec by_date!(Date.t, gender, String.t, Date.t) :: rank_by_date | no_return
  def by_date!(dob, gender, country, date) do
    GenServer.call(__MODULE__, {:get_rank_by_date!, dob, gender, country, date})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by the person's age.

  Returns `{:ok, rank_by_age}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.by_age(~D[1992-06-21], :unisex, "Colombia", {24, 5})
      {:ok,
       %{age: "24y5m0d", country: "Colombia", dob: "1992-06-21", rank: 21567777,
         sex: :unisex}}
      iex> Population.Rank.by_age(~D[1992-06-21], :random, "Colombia", {24, 5})
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec by_age(Date.t, gender, String.t, offset) :: {:ok, rank_by_age} | failure
  def by_age(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age, dob, gender, country, age})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by the person's age.

  Returns `rank_by_age` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.Rank.by_age!(~D[1992-06-21], :unisex, "Colombia", {24, 5})
      %{age: "24y5m0d", country: "Colombia", dob: "1992-06-21", rank: 21567777,
        sex: :unisex}
      iex> Population.Rank.by_age!(~D[1992-06-21], :random, "Colombia", {24, 5})
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec by_age!(Date.t, gender, String.t, offset) :: rank_by_age | no_return
  def by_age!(dob, gender, country, age) do
    GenServer.call(__MODULE__, {:get_rank_by_age!, dob, gender, country, age})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by an offset towards
  the past from today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `{:ok, rank_with_offset}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.in_past(~D[1992-06-21], :unisex, "Colombia", {2, 6})
      {:ok,
       %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 19478549,
         sex: :unisex}}
      iex> Population.Rank.in_past(~D[1992-06-21], :random, "Colombia", {2, 6})
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec in_past(Date.t, gender, String.t, offset) :: {:ok, rank_with_offset} | failure
  def in_past(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past, dob, gender, country, ago})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by an offset towards
  the past from today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `rank_with_offset` if the call succeed, raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.Rank.in_past!(~D[1992-06-21], :unisex, "Colombia", {2, 6})
      %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 19478549,
        sex: :unisex}
      iex> Population.Rank.in_past!(~D[1992-06-21], :random, "Colombia", {2, 6})
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec in_past!(Date.t, gender, String.t, offset) :: rank_with_offset | no_return
  def in_past!(dob, gender, country, ago) do
    GenServer.call(__MODULE__, {:get_rank_in_past!, dob, gender, country, ago})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by an offset towards
  the future from today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `{:ok, rank_with_offset}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.in_future(~D[1992-06-21], :unisex, "Colombia", {2, 6})
      {:ok,
       %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 23711438,
         sex: :unisex}}
      iex> Population.Rank.in_future(~D[1992-06-21], :random, "Colombia", {2, 6})
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec in_future(Date.t, gender, String.t, offset) :: {:ok, rank_with_offset} | failure
  def in_future(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future, dob, gender, country, future_date})
  end

  @doc """
  Calculates the world population rank of a person with the given date of birth,
  sex and country of origin on a certain date as expressed by an offset towards
  the future from today.

  Today's date is always based on the current time in the timezone UTC.

  Returns `rank_with_offset` if the call succeed, raises a `RuntimeError` with a
  message including the `reason`.

  ## Examples

      iex> Population.Rank.in_future!(~D[1992-06-21], :unisex, "Colombia", {2, 6})
      %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 23711438,
        sex: :unisex}
      iex> Population.Rank.in_future!(~D[1992-06-21], :random, "Colombia", {2, 6})
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec in_future!(Date.t, gender, String.t, offset) :: rank_with_offset | no_return
  def in_future!(dob, gender, country, future_date) do
    GenServer.call(__MODULE__, {:get_rank_in_future!, dob, gender, country, future_date})
  end

  @doc """
  Calculates the day on which a person with the given date of birth, sex and
  country of origin has reached (or will reach) a certain world population rank.

  Returns `{:ok, date_by_rank}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Rank.date_by_rank(~D[1992-06-21], :unisex, "Colombia", 1_000_000)
      {:ok,
       %{country: "Colombia", date_on_rank: "1993-07-29", dob: "1992-06-21",
         rank: 1000000, sex: :unisex}}
      iex> Population.Rank.date_by_rank(~D[0600-06-21], :unisex, "Colombia", 1_000_000)
      {:error,
       "The birthdate 0600-06-21 can not be processed, only dates between 1920-01-01 and 2059-12-31 are supported"}

  """
  @spec date_by_rank(Date.t, gender, String.t, integer) :: {:ok, date_by_rank} | failure
  def date_by_rank(dob, gender, country, rank) do
    GenServer.call(__MODULE__, {:get_date_by_rank, dob, gender, country, rank})
  end

  @doc """
  Calculates the day on which a person with the given date of birth, sex and
  country of origin has reached (or will reach) a certain world population rank.

  Returns `date_by_rank` if the call succeed, raises a `RuntimeError` with a
  message including the `reason`.

  ## Examples

      iex> Population.Rank.date_by_rank!(~D[1992-06-21], :unisex, "Colombia", 1_000_000)
      %{country: "Colombia", date_on_rank: "1993-07-29", dob: "1992-06-21",
        rank: 1000000, sex: :unisex}
      iex> Population.Rank.date_by_rank!(~D[0600-06-21], :unisex, "Colombia", 1_000_000)
      ** (RuntimeError) The birthdate 0600-06-21 can not be processed, only dates between 1920-01-01 and 2059-12-31 are supported

  """
  @spec date_by_rank!(Date.t, gender, String.t, integer) :: date_by_rank | no_return
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

  defp url_path_for_today(dob, gender, country) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/today/"
  end

  defp url_path_by_date(dob, gender, country, date) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/on/#{Date.to_string(date)}/"
  end

  defp url_path_by_age(dob, gender, country, age) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/aged/#{format_date_offset(age)}/"
  end

  defp url_path_in_past(dob, gender, country, ago) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/ago/#{format_date_offset(ago)}/"
  end

  defp url_path_in_future(dob, gender, country, future) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/in/#{format_date_offset(future)}/"
  end

  defp url_path_for_date_by_rank(dob, gender, country, rank) do
    "wp-rank/#{Date.to_string(dob)}/#{gender}/#{encode_country(country)}/ranked/#{rank}/"
  end
end
