defmodule Population.Country do

  use GenServer

  import Population.API,
    only: [fetch_data: 1, handle_reply: 2, handle_reply!: 1]

  @typep countries :: Population.Types.countries
  @typep country_response  :: Population.Types.country_response
  @typep implicit_response :: Population.Types.implicit_response

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec list() :: country_response
  def list do
    GenServer.call(__MODULE__, :get_countries)
    |> handle_result
  end

  @spec list!() :: countries | no_return
  def list! do
    GenServer.call(__MODULE__, :get_countries!)
    |> handle_result!
  end

  # GenServer CallBacks

  def handle_call(:get_countries, _from, state) do
    fetch_data("countries")
    |> handle_reply(state)
  end
  def handle_call(:get_countries!, _from, _state) do
    fetch_data("countries")
    |> handle_reply!
  end

  # Helper Functions

  @spec handle_result(implicit_response) :: country_response
  defp handle_result({:ok, resp}), do: {:ok, resp["countries"]}
  defp handle_result(failure = {:error, _reason}), do: failure

  @spec handle_result(Map.t) :: countries
  defp handle_result!(resp) when is_map(resp), do: resp["countries"]
end
