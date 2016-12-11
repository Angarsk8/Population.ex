defmodule Population.CommonTypes do

  @type failure :: {:error, String.t}
  @type gender  :: :male | :female
  @type year    :: integer
  @type month   :: 0..12
  @type day     :: 0..31
  @type offset  :: {year, month, day}
                 | {year, month}
                 | {year}
end
