defmodule Population.Helpers.DateFormat do

  @typep date   :: Population.Types.date
  @typep offset :: Population.Types.offset

  @spec format_date(date) :: String.t
  def format_date({year, month, day}), do: "#{year}-#{month}-#{day}"

  @spec format_date_offset(offset) :: String.t
  def format_date_offset({year, month, day}), do: "#{year}y#{month}m#{day}d"
  def format_date_offset({year, month}), do: "#{year}y#{month}m"
  def format_date_offset({year}), do: "#{year}y"
end
