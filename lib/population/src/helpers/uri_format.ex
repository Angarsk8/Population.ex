defmodule Population.Helpers.URIFormat do

  @moduledoc """
  This module provides some helper functions for encoding the requests params.
  """

  @doc """
  Capitalizes the country name and percent-escapes the given result.

  ## Examples

      iex> Population.Helpers.URIFormat.encode_country("united kingdom")
      "United%20Kingdom"
      iex> Population.Helpers.URIFormat.encode_country("czech republic")
      "Czech%20Republic"

  """
  @spec encode_country(country :: String.t) :: String.t
  def encode_country(country) do
    country
    |> capitalize_country
    |> URI.encode
  end

  @spec capitalize_country(country :: String.t) :: String.t
  defp capitalize_country(country) do
    country
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
