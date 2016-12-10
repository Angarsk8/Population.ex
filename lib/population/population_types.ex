defmodule Population.Types do

  defmacro __using__(_opts) do
    quote do
      @type gender :: :male | :female
      @type year   :: pos_integer
      @type age    :: integer
      @type month  :: 1..12
      @type day    :: 1..31
      @type date   :: Date.t
      @type offset :: {year, month, day}
                    | {year, month}
                    | {year}

      @type wgender :: gender | :unisex

      @type response :: remaining_life
                      | total_life
                      | mortality_dist
                      | population_tables
                      | map

      @type success  :: {:ok, response}
      @type failure  :: {:error, String.t}

      @type implicit_response :: success  | failure

      # Country Types

      @type country   :: String.t
      @type countries :: [country]

      # Life Expectancy Types

      @type remaining_life :: %{
        sex: gender,
        country: country,
        date: String.t,
        remaining_life_expectancy: float
      }

      @type total_life :: %{
        sex: gender,
        country: country,
        date: String.t,
        total_life_expectancy: float
      }

      # Mortality Distribution Types

      @type mortality_table :: %{
        age: age,
        mortality_percent: float
      }

      @type mortality_dist  :: [mortality_table]

      # World Population Rank Types

      @type rank_today :: %{
        dob: String.t,
        sex: wgender,
        country: country,
        rank: integer
      }

      @type rank_by_date :: %{
        dob: String.t,
        sex: wgender,
        country: country,
        rank: integer,
        date: String.t
      }

      @type rank_by_age :: %{
        dob: String.t,
        sex: wgender,
        country: country,
        rank: integer,
        age: String.t
      }

      @type rank_with_offset :: %{
        dob: String.t,
        sex: wgender,
        country: country,
        rank: integer,
        offset: String.t
      }

      @type date_by_rank :: %{
        dob: String.t,
        sex: wgender,
        country: country,
        rank: integer,
        date_on_rank: String.t
      }

      # World Population Table Types

      @type population_table :: %{
        total: integer,
        females: integer,
        males: integer,
        year: year,
        age: age
      }

      @type population_tables :: [population_table]

      @type total_population :: %{
        date: String.t,
        population: integer
      }

      @type population_contrast :: %{
        today: total_population,
        tomorrow: total_population
      }
    end
  end
end
