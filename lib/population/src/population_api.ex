defmodule Population.API do

  @moduledoc """
  This module defines functions for fetching, handling and replying the data from
  the [population.io](http://population.io) REST API.
  """

  @api_url Application.get_env(:population, :api_url)

  @type state    :: map() | [String.t | map()]
  @type response :: map() | [map()]
  @type success  :: {:ok, response}
  @type failure  :: {:error, String.t}

  @doc """
  Fetches the data from the [population.io](http://population.io) API given a URL `path` and handles the result.

  Returns `{:ok, response}` if the call succeed, otherwise `{:error, reason}`.

  ## Examples

      iex> Population.API.fetch_data("countries")
      {:ok,
       %{"countries" => ["Afghanistan", "Albania", "Algeria", ...]}}
      iex> Population.API.fetch_data("population/Westeros/today-and-tomorrow/")
      {:error,
       "Westeros is an invalid value for the parameter \"country\", the list of valid values can be retrieved from the endpoint /countries"}

  """
  @spec fetch_data(String.t) :: success | failure
  def fetch_data(path) do
    path
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end

  @doc """
  Handles the reply back to the GenServer that invoked this function, given a response
  of the format `{:ok, response} | {:error, detail}`, and the current server `state`.

  ## Examples

      iex> Population.API.handle_reply({:ok, %{"foo" => :bar, "bar" => :foo}}, %{})
      {:reply, {:ok, %{bar: :foo, foo: :bar}}, %{bar: :foo, foo: :bar}}
      iex> Population.API.handle_reply({:error, "reason"}, %{bar: :foo, foo: :bar})
      {:reply, {:error, "reason"}, %{bar: :foo, foo: :bar}}

  """
  @spec handle_reply(success | failure, state) :: {:reply, success | failure, state}
  def handle_reply(expr, state) do
    case expr do
      {:ok, resp} ->
        {:reply, {:ok, atomize_response(resp)}, atomize_response(resp)}
      failure ->
        {:reply, failure, state}
    end
  end

  @doc """
  Handles explicitely the reply back to the GenServer that invoked this function,
  given a response of the format `{:ok, response} | {:error, detail}`.

  ## Examples

      iex> Population.API.handle_reply!({:ok, %{"foo" => :bar, "bar" => :foo}})
      {:reply, %{bar: :foo, foo: :bar}, %{bar: :foo, foo: :bar}}
      iex> Population.API.handle_reply!({:error, "reason"})
      ** (RuntimeError) reason

  """
  @spec handle_reply!(success | failure) :: {:reply, response, state} | no_return
  def handle_reply!(expr) do
    case expr do
      {:ok, resp}  ->
        {:reply, atomize_response(resp), atomize_response(resp)}
      {:error, reason} ->
        raise reason
    end
  end

  defp url_for(path) do
    "#{@api_url}#{path}"
  end

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
