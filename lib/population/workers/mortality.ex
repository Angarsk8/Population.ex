defmodule Population.Mortality do

  @moduledoc """
  This module defines functions to get the mortality distribution of a country,
  given some information such as `gender` and `age`.

  See more in [api.population.io/mortality-distribution](http://api.population.io/#!/mortality-distribution)
  """

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  @type failure :: Population.CommonTypes.failure
  @type gender  :: Population.CommonTypes.gender
  @type offset  :: Population.CommonTypes.offset

  @type mortality_table :: %{
    age: integer,
    mortality_percent: float
  }

  @type mortality_dist :: [mortality_table]

  # Cient API

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Retrieves the mortality distribution tables for the given country, sex and age.

  Returns `{:ok, mortality_dist}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.Mortality.distribution("Colombia", :female, {49, 2})
      {:ok,
       [%{age: 45.0, mortality_percent: 0.0},
        %{age: 50.0, mortality_percent: 0.25014423810470543},
        %{age: 55.0, mortality_percent: 2.1978408779738965},
        %{age: 60.0, mortality_percent: 3.0818990812279665},
        ...]}
      iex> Population.Mortality.distribution("Colombia", :random, {49, 2})
      {:error,
       "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

  """
  @spec distribution(String.t, gender, offset) :: {:ok, mortality_dist} | failure
  def distribution(country, gender, age) do
    result = GenServer.call(__MODULE__, {:get_mortality_distribution, country, gender, age})
    case result do
      {:ok, %{mortality_distribution: distribution}} ->
        {:ok, distribution}
      _ ->
        result
    end
  end

  @doc """
  Retrieves the mortality distribution tables for the given country, sex and age.

  Returns `mortality_dist` if the call succeed, otherwise raises a `RuntimeError` with
  a message including the `reason`.

  ## Examples

      iex> Population.Mortality.distribution!("Colombia", :female, {49, 2})
      [%{age: 45.0, mortality_percent: 0.0},
       %{age: 50.0, mortality_percent: 0.25014423810470543},
       %{age: 55.0, mortality_percent: 2.1978408779738965},
       %{age: 60.0, mortality_percent: 3.0818990812279665},
       ...]
      iex> Population.Mortality.distribution!("Colombia", :random, {49, 2})
      ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

  """
  @spec distribution!(String.t, gender, offset) :: mortality_dist | no_return
  def distribution!(country, gender, age) do
    %{mortality_distribution: distribution} =
      GenServer.call(__MODULE__, {:get_mortality_distribution!, country, gender, age})
    distribution
  end

  # GenServer CallBacks

  def handle_call({:get_mortality_distribution, country, gender, age}, _from, state) do
    url_path_for_distribution(country, gender, age)
    |> fetch_data
    |> handle_reply(state)
  end
  def handle_call({:get_mortality_distribution!, country, gender, age}, _from, _state) do
    url_path_for_distribution(country, gender, age)
    |> fetch_data
    |> handle_reply!
  end

  # Helper Functions

  defp url_path_for_distribution(country, gender, age) do
    "mortality-distribution/#{encode_country(country)}/#{gender}/#{format_date_offset(age)}/today/"
  end
end
