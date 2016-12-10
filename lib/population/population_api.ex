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
# Population.LifeExpectancy.remaining!(:female, "ecuador", ~D[1992-06-21], {18, 2})
# Population.LifeExpectancy.total(:female, "ecuador", ~D[1992-06-21])
# Population.LifeExpectancy.total!(:female, "ecuador", ~D[1992-06-21])
# Population.Mortality.distribution!("Colombia", :male, {18, 2})
