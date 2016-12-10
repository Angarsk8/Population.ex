defmodule Population.API do

  use Population.Types

  @api_url Application.get_env(:population, :api_url)

  @type request_response  :: {:ok, Response.t | AsyncResponse.t}
                           | {:error, Error.t}

  @typep state :: map | [String.t | map] | []

  @spec fetch_data(String.t) :: implicit_response
  def fetch_data(path) do
    path
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end

  @spec handle_reply(implicit_response, state) :: {:reply, implicit_response, state}
  def handle_reply(expr, state) do
    case expr do
      {:ok, resp} ->
        {:reply, {:ok, atomize_response(resp)}, atomize_response(resp)}
      failure ->
        {:reply, failure, state}
    end
  end

  @spec handle_reply!(implicit_response) :: {:reply, response, state} | no_return
  def handle_reply!(expr) do
    case expr do
      {:ok, resp}  ->
        {:reply, atomize_response(resp), atomize_response(resp)}
      {:error, reason} ->
        raise reason
    end
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

  @spec atomize_response(response) :: response
  defp atomize_response(response) when is_list(response) do
    for el <- response do
      atomize_response(el)
    end
  end
  defp atomize_response(response) when is_map(response) do
    for {key, val} <- response, into: %{} do
      cond do
        key == "sex" ->
          {String.to_atom(key), String.to_atom(val)}
        true ->
          {String.to_atom(key), atomize_response(val)}
      end
    end
  end
  defp atomize_response(response), do: response
end
