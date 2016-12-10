defmodule Population.API do

  use Population.Types

  @api_url Application.get_env(:population, :api_url)

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

  @spec handle_reply(implicit_response, Mat.t) :: implicit_response
  def handle_reply(expr, state) do
    case expr do
      {:ok, resp} = success ->
        {:reply, success, resp}
      failure ->
        {:reply, failure, state}
    end
  end

  @spec handle_reply!(implicit_response) :: explicit_response
  def handle_reply!(expr) do
    case expr do
      {:ok, resp}  ->
        {:reply, resp, resp}
      {:error, reason} ->
        raise reason
    end
  end
end
