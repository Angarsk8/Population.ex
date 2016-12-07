defmodule Population.Types do

  @type countries :: [String.t]
  @type country_response :: {:ok, countries} | failure

  @type gender :: :male | :female | :unisex

  @type year   :: pos_integer
  @type month  :: 1..12
  @type day    :: 1..31
  @type date   :: {year, month, day}
  @type offset :: {year} | {year, month} | {year, month, day}

  @type success  :: {:ok, Map.t}
  @type failure  :: {:error, String.t}

  @type implicit_response :: success | failure
  @type explicit_response :: Map.t | no_return
end
