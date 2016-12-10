defmodule Population.Helpers.URIFormat do

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
