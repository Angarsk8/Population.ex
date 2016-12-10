defmodule Population.Mortality do

  use GenServer
  use Population.Types

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  import Population.Helpers.DateFormat, only: [format_date_offset: 1]
  import Population.Helpers.URIFormat , only: [encode_country: 1]

  # Cient API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec distribution(country, gender, offset) :: {:ok, mortality_dist} | failure
  def distribution(country, gender, age) do
    result = GenServer.call(__MODULE__, {:get_mortality_distribution, country, gender, age})
    case result do
      {:ok, %{mortality_distribution: distribution}} ->
        {:ok, distribution}
      _ ->
        result
    end
  end

  @spec distribution!(country, gender, offset) :: mortality_dist | no_return
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

  @spec url_path_for_distribution(country, gender, offset) :: String.t
  def url_path_for_distribution(country, gender, age) do
    "mortality-distribution/#{encode_country(country)}/#{gender}/#{format_date_offset(age)}/today/"
  end
end
