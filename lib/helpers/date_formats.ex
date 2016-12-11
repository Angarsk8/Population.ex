defmodule Population.Helpers.DateFormat do

  @moduledoc """
  This module defines some helper functions to format `Date` related data.
  """

  @type offset  :: Population.CommonTypes.offset

  @doc """
  Converts a given offset of the form `{year, month, day}`, `{year, month}` or
  `{year}` to a string in the form `"\#{year}y\#{month}m\#{day}d"`,
  `"\#{year}y\#{month}m"` or `\#{year}y` respectively.

  ## Examples
      iex> Population.Helpers.DateFormat.format_date_offset({2, 5, 30})
      "2y5m30d"
      iex> Population.Helpers.DateFormat.format_date_offset({2, 5})
      "2y5m"
      iex> Population.Helpers.DateFormat.format_date_offset({2})
      "2y"

  """
  @spec format_date_offset(offset) :: String.t
  def format_date_offset({year, month, day}), do: "#{year}y#{month}m#{day}d"
  def format_date_offset({year, month}), do: "#{year}y#{month}m"
  def format_date_offset({year}), do: "#{year}y"
end
