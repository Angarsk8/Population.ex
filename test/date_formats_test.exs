defmodule Population.Helpers.DateFormat.Test do

  use ExUnit.Case, async: true
  doctest Population.Helpers.DateFormat

  import Population.Helpers.DateFormat

  test "Creates a string offset when a year, a month and a day are given" do
    offset = {2, 10, 30}
    assert format_date_offset(offset) == "2y10m30d"
  end

  test "Creates a string offset when only a year and a month are given" do
    offset = {2, 10}
    assert format_date_offset(offset) == "2y10m"
  end

  test "Creates a string offset when only a year is given" do
    offset = {2}
    assert format_date_offset(offset) == "2y"
  end
end
