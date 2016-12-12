defmodule Population.Helpers.URIFormat.Test do

  use ExUnit.Case
  doctest Population.Helpers.URIFormat

  import Population.Helpers.URIFormat

  test "Converts a string to uppercase and encode it into an URI string" do
    assert encode_country("colombia") == "Colombia"
    assert encode_country("united kingdom") == "United%20Kingdom"
    assert encode_country("sudáfrica") == "Sud%C3%A1frica"
  end
end
