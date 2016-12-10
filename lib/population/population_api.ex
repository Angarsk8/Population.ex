defmodule Population.API do

  use Population.Types

  @api_url Application.get_env(:population, :api_url)

  @type request_response  :: {:ok, Response.t | AsyncResponse.t}
                           | {:error, Error.t}

  @spec fetch_data(String.t) :: implicit_response
  def fetch_data(path) do
    path
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end

  @spec url_for(String.t) :: String.t
  defp url_for(path) do
    "#{@api_url}#{path}"
  end

  @spec handle_response(request_response) :: implicit_response
  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    json = JSON.decode!(body)
    {:ok, json}
  end
  defp handle_response({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    json = JSON.decode!(body)
    {:error, json["detail"]}
  rescue
    _ ->
      {:error, "An error ocurred while retrieveing the information"}
  end
  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, to_string(reason)}
  end

  @spec handle_reply(implicit_response, map | [String.t | map]) :: implicit_response
  def handle_reply(expr, state) do
    case expr do
      {:ok, resp} ->
        {:reply, {:ok, atomize_keys(resp)}, atomize_keys(resp)}
      failure ->
        {:reply, failure, state}
    end
  end

  @spec handle_reply!(implicit_response) :: explicit_response
  def handle_reply!(expr) do
    case expr do
      {:ok, resp}  ->
        {:reply, atomize_keys(resp), atomize_keys(resp)}
      {:error, reason} ->
        raise reason
    end
  end

  defp atomize_keys(response) when is_list(response) do
    for el <- response do
      atomize_keys(el)
    end
  end
  defp atomize_keys(response) when is_map(response) do
    for {key, val} <- response, into: %{} do
      {String.to_atom(key), atomize_keys(val)}
    end
  end
  defp atomize_keys(response), do: response
end

# Population.Country.list
# Population.Country.list!
# Population.LifeExpectancy.remaining(:male, "colombia", ~D[1992-06-21], {18, 2})
# Population.LifeExpectancy.remaining!(:female, "colombia", ~D[1992-06-21], {18, 2})
# Population.LifeExpectancy.total(:female, "colombia", ~D[1992-06-21])
# Population.LifeExpectancy.total!(:female, "colombia", ~D[1992-06-21])
# Population.Mortality.distribution!("Colombia", :male, {18, 2})
# Population.Table.all(1992, 18)
# Population.Table.all!(1992, 18)
# Population.Table.all_ages_by_country("colombia", 2012)
# Population.Table.all_ages_by_country!("colombia", 2012)
# Population.Table.all_years_by_country("colombia", 18)
# Population.Table.all_years_by_country!("colombia", 18)
# Population.Table.by_country("colombia", 2001, 18)
# Population.Table.by_country!("colombia", 2001, 18)
# Population.Table.for_country_by_date("colombia", ~D[2015-06-21])
# Population.Table.for_country_by_date!("colombia", ~D[2015-06-21])
# Population.Table.for_today_and_tomorrow_by_country("colombia")
# Population.Table.for_today_and_tomorrow_by_country!("colombia")
# Population.Rank.by_age(~D[1992-06-21] , :male, "Colombia", {24, 5})
# Population.Rank.by_age!(~D[1992-06-21], :male, "Colombia", {24, 5})
# Population.Rank.by_date(~D[1992-06-21], :male, "Colombia", ~D[2016-12-12])
# Population.Rank.by_date!(~D[1992-06-21], :male, "Colombia", ~D[2016-12-12])
# Population.Rank.date_by_rank(~D[1992-06-21], :male, "Colombia", 10000000)
# Population.Rank.date_by_rank!(~D[1992-06-21], :male, "Colombia", 10000000)
# Population.Rank.in_future(~D[1992-06-21], :male, "Colombia", {2, 5})
# Population.Rank.in_future!(~D[1992-06-21], :male, "Colombia", {2, 5})
# Population.Rank.in_past(~D[1992-06-21], :male, "Colombia", {2, 5})
# Population.Rank.in_past!(~D[1992-06-21], :male, "Colombia", {2, 5})
