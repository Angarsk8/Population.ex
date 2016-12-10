defmodule Population.Types do

  defmacro __using__(_opts) do
    quote do
      @type country   :: String.t
      @type countries :: [country]

      @type gender :: :male | :female | :unisex
      @type year   :: pos_integer
      @type age    :: integer
      @type month  :: 1..12
      @type day    :: 1..31
      @type date   :: {year, month, day}
      @type offset :: {year} | {year, month} | {year, month, day}

      @type population_table    :: [Map.t]
      @type population_contrast :: {Map.t, Map.t}

      @type response :: countries
                      | population_table
                      | population_contrast
                      | Map.t

      @type success  :: {:ok, response}
      @type failure  :: {:error, String.t}

      @type implicit_response :: success  | failure
      @type explicit_response :: response | no_return

      @typep request_response  :: {:ok, Response.t | AsyncResponse.t}
                                | {:error, Error.t}
    end
  end
end
