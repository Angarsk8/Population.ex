defmodule Population.Base do

  @moduledoc """
  Provides a default implementation for the Population functions.

  This module is meant to be `use`'d in custom modules in order to wrap the
  functionalities provided by the registered Population GenServers under the
  `/lib/population/src/workers` directory.
  """

  defmacro __using__(_opts) do
    quote do

      # Common Types

      @type gender  :: :male | :female
      @type year    :: integer
      @type month   :: 0..12
      @type day     :: 0..31
      @type offset  :: {year, month, day}
                     | {year, month}
                     | {year}

      @type failure  :: {:error, String.t}

      # Country Types

      @type countries :: [String.t]

      # Life Expectancy Types

      @type remaining_life :: %{
        sex: gender,
        country: String.t,
        date: String.t,
        remaining_life_expectancy: float
      }

      @type total_life :: %{
        sex: gender,
        country: String.t,
        date: String.t,
        total_life_expectancy: float
      }

      # Mortality Distribution Types

      @type mortality_table :: %{
        age: integer,
        mortality_percent: float
      }

      @type mortality_dist :: [mortality_table]

      # World Population Rank Types

      @type rgender :: gender | :unisex

      @type rank_today :: %{
        dob: String.t,
        sex: rgender,
        country: String.t,
        rank: integer
      }

      @type rank_by_date :: %{
        dob: String.t,
        sex: rgender,
        country: String.t,
        rank: integer,
        date: String.t
      }

      @type rank_by_age :: %{
        dob: String.t,
        sex: rgender,
        country: String.t,
        rank: integer,
        age: String.t
      }

      @type rank_with_offset :: %{
        dob: String.t,
        sex: rgender,
        country: String.t,
        rank: integer,
        offset: String.t
      }

      @type date_by_rank :: %{
        dob: String.t,
        sex: rgender,
        country: String.t,
        rank: integer,
        date_on_rank: String.t
      }

      # World Population Table Types

      @type valid_year :: 1950..2100
      @type valid_age  :: 0..100

      @type population_table :: %{
        total: integer,
        females: integer,
        males: integer,
        year: valid_year,
        age: valid_age
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

      @doc """
      Retrieves a list of all countries in the statistical dataset.

      Returns `{:ok, ``t:countries/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> countries
          {:ok, ["Afghanistan", "Albania", "Algeria", ...]}

      """
      @spec countries() :: {:ok, countries} | failure
      def countries() do
        Population.Country.list
      end

      @doc """
      Retrieves a list of all countries in the statistical dataset.

      Returns the list of `t:countries/0` if the call succeed, otherwise raises
      a `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> countries!
          ["Afghanistan", "Albania", "Algeria", ...]

      """
      @spec countries!() :: countries | no_return
      def countries!() do
        Population.Country.list!
      end

      @doc """
      Calculates the remaining life expectancy of a person with given sex, country,
      and age at a given point in time.

      Returns `{:ok, ``t:remaining_life/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> remaining_life_expectancy(:male, "Colombia", ~D[2016-12-10], {24, 5})
          {:ok,
           %{age: "24y5m0d", country: "Colombia", date: "2016-12-10",
             remaining_life_expectancy: 54.63260155466486, sex: :male}}
          iex> remaining_life_expectancy(:random, "Colombia", ~D[2016-12-10], {24, 5})
          {:error, "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec remaining_life_expectancy(gender, String.t, Date.t, offset) :: {:ok, remaining_life} | failure
      def remaining_life_expectancy(gender, country, date, age) do
        Population.LifeExpectancy.remaining(gender, country, date, age)
      end

      @doc """
      Calculates the remaining life expectancy of a person with given sex, country,
      and age at a given point in time.

      Returns `t:remaining_life/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> remaining_life_expectancy!(:male, "Colombia", ~D[2016-12-10], {24, 5})
          %{age: "24y5m0d", country: "Colombia", date: "2016-12-10",
            remaining_life_expectancy: 54.63260155466486, sex: :male}
          iex> remaining_life_expectancy!(:random, "Colombia", ~D[2016-12-10], {24, 5})
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec remaining_life_expectancy!(gender, String.t, Date.t, offset) :: remaining_life | no_return
      def remaining_life_expectancy!(gender, country, date, age) do
        Population.LifeExpectancy.remaining!(gender, country, date, age)
      end

      @doc """
      Calculates the total life expectancy of a person with given sex, country, and date
      of birth.

      Returns `{:ok, ``t:total_life/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> total_life_expectancy(:male, "Colombia", ~D[1992-06-21])
          {:ok,
           %{country: "Colombia", dob: "1992-06-21", sex: :male,
             total_life_expectancy: 80.89666673632185}}
          iex> total_life_expectancy(:random, "Colombia", ~D[1992-06-21])
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec total_life_expectancy(gender, String.t, Date.t) :: {:ok, total_life} | failure
      def total_life_expectancy(gender, country, dob) do
        Population.LifeExpectancy.total(gender, country, dob)
      end

      @doc """
      Calculates the total life expectancy of a person with given sex, country, and date
      of birth.

      Returns `t:total_life/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> total_life_expectancy!(:male, "Colombia", ~D[1992-06-21])
          %{country: "Colombia", dob: "1992-06-21", sex: :male,
            total_life_expectancy: 80.89666673632185}
          iex> total_life_expectancy!(:male, "Westeros", ~D[1992-06-21])
          ** (RuntimeError) Westeros is an invalid value for the parameter
          "country", the list of valid values can be retrieved from the endpoint /countries

      """
      @spec total_life_expectancy!(gender, String.t, Date.t) :: total_life | no_return
      def total_life_expectancy!(gender, country, dob) do
        Population.LifeExpectancy.total!(gender, country, dob)
      end

      @doc """
      Retrieves the mortality distribution tables for the given country, sex and age.

      Returns `{:ok, ``t:mortality_dist/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> mortality_distribution("Colombia", :female, {49, 2})
          {:ok,
           [%{age: 45.0, mortality_percent: 0.0},
            %{age: 50.0, mortality_percent: 0.25014423810470543},
            %{age: 55.0, mortality_percent: 2.1978408779738965},
            %{age: 60.0, mortality_percent: 3.0818990812279665},
            ...]}
          iex> mortality_distribution("Colombia", :random, {49, 2})
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec mortality_distribution(String.t, gender, offset) :: {:ok, mortality_dist} | failure
      def mortality_distribution(country, gender, age) do
        Population.Mortality.distribution(country, gender, age)
      end

      @doc """
      Retrieves the mortality distribution tables for the given country, sex and age.

      Returns `t:mortality_dist/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> mortality_distribution!("Colombia", :female, {49, 2})
          [%{age: 45.0, mortality_percent: 0.0},
           %{age: 50.0, mortality_percent: 0.25014423810470543},
           %{age: 55.0, mortality_percent: 2.1978408779738965},
           %{age: 60.0, mortality_percent: 3.0818990812279665},
           ...]
          iex> mortality_distribution!("Colombia", :random, {49, 2})
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec mortality_distribution!(String.t, gender, offset) :: mortality_dist | no_return
      def mortality_distribution!(country, gender, age) do
        Population.Mortality.distribution!(country, gender, age)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin as of today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `{:ok, ``t:rank_today/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> rank_today(~D[1992-06-21], :unisex, "Colombia")
          {:ok, %{country: "Colombia", dob: "1992-06-21", rank: 21614190, sex: :unisex}}
          iex> rank_today(~D[1992-06-21], :random, "Colombia")
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec rank_today(Date.t, gender, String.t) :: {:ok, rank_today} | failure
      def rank_today(dob, gender, country) do
        Population.Rank.today(dob, gender, country)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin as of today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `t:rank_today/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> rank_today!(~D[1992-06-21], :unisex, "Colombia")
          %{country: "Colombia", dob: "1992-06-21", rank: 21614190, sex: :unisex}
          iex> rank_today!(~D[1992-06-21], :random, "Colombia")
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec rank_today!(Date.t, gender, String.t) :: rank_today | no_return
      def rank_today!(dob, gender, country) do
        Population.Rank.today!(dob, gender, country)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date.

      Returns `{:ok, ``t:rank_by_date/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> rank_by_date(~D[1992-06-21], :unisex, "Colombia", ~D[2016-12-10])
          {:ok,
           %{country: "Colombia", date: "2016-12-10", dob: "1992-06-21", rank: 21611869,
             sex: :unisex}}
          iex> rank_by_date(~D[1992-06-21], :random, "Colombia", ~D[2016-12-10])
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec rank_by_date(Date.t, gender, String.t, Date.t) :: {:ok, rank_by_date} | failure
      def rank_by_date(dob, gender, country, date) do
        Population.Rank.by_date(dob, gender, country, date)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date.

      Returns `t:rank_by_date/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> rank_by_date!(~D[1992-06-21], :unisex, "Colombia", ~D[2016-12-10])
          %{country: "Colombia", date: "2016-12-10", dob: "1992-06-21", rank: 21611869,
            sex: :unisex}
          iex> rank_by_date!(~D[1992-06-21], :random, "Colombia", ~D[2016-12-10])
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec rank_by_date!(Date.t, gender, String.t, Date.t) :: rank_by_date | no_return
      def rank_by_date!(dob, gender, country, date) do
        Population.Rank.by_date!(dob, gender, country, date)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by the person's age.

      Returns `{:ok, ``t:rank_by_age/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> rank_by_age(~D[1992-06-21], :unisex, "Colombia", {24, 5})
          {:ok,
           %{age: "24y5m0d", country: "Colombia", dob: "1992-06-21", rank: 21567777,
             sex: :unisex}}
          iex> rank_by_age(~D[1992-06-21], :random, "Colombia", {24, 5})
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec rank_by_age(Date.t, gender, String.t, offset) :: {:ok, rank_by_age} | failure
      def rank_by_age(dob, gender, country, age) do
        Population.Rank.by_age(dob, gender, country, age)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by the person's age.

      Returns `t:rank_by_age/0` if the call succeed, otherwise raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> rank_by_age!(~D[1992-06-21], :unisex, "Colombia", {24, 5})
          %{age: "24y5m0d", country: "Colombia", dob: "1992-06-21", rank: 21567777,
            sex: :unisex}
          iex> rank_by_age!(~D[1992-06-21], :random, "Colombia", {24, 5})
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec rank_by_age!(Date.t, gender, String.t, offset) :: rank_by_age | no_return
      def rank_by_age!(dob, gender, country, age) do
        Population.Rank.by_age!(dob, gender, country, age)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by an offset towards
      the past from today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `{:ok, ``t:rank_with_offset/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> rank_in_past(~D[1992-06-21], :unisex, "Colombia", {2, 6})
          {:ok,
           %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 19478549,
             sex: :unisex}}
          iex> rank_in_past(~D[1992-06-21], :random, "Colombia", {2, 6})
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec rank_in_past(Date.t, gender, String.t, offset) :: {:ok, rank_with_offset} | failure
      def rank_in_past(dob, gender, country, ago) do
        Population.Rank.in_past(dob, gender, country, ago)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by an offset towards
      the past from today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `t:rank_with_offset/0` if the call succeed, raises a `RuntimeError` with
      a message including the `reason`.

      ## Examples

          iex> rank_in_past!(~D[1992-06-21], :unisex, "Colombia", {2, 6})
          %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 19478549,
            sex: :unisex}
          iex> rank_in_past!(~D[1992-06-21], :random, "Colombia", {2, 6})
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec rank_in_past!(Date.t, gender, String.t, offset) :: rank_with_offset | no_return
      def rank_in_past!(dob, gender, country, ago) do
        Population.Rank.in_past(dob, gender, country, ago)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by an offset towards
      the future from today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `{:ok, ``t:rank_with_offset/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> rank_in_future(~D[1992-06-21], :unisex, "Colombia", {2, 6})
          {:ok,
           %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 23711438,
             sex: :unisex}}
          iex> rank_in_future(~D[1992-06-21], :random, "Colombia", {2, 6})
          {:error,
           "random is an invalid value for the parameter \"sex\", valid values are: male, female, unisex"}

      """
      @spec rank_in_future(Date.t, gender, String.t, offset) :: {:ok, rank_with_offset} | failure
      def rank_in_future(dob, gender, country, future_date) do
        Population.Rank.in_future(dob, gender, country, future_date)
      end

      @doc """
      Calculates the world population rank of a person with the given date of birth,
      sex and country of origin on a certain date as expressed by an offset towards
      the future from today.

      Today's date is always based on the current time in the timezone UTC.

      Returns `t:rank_with_offset/0` if the call succeed, raises a `RuntimeError` with a
      message including the `reason`.

      ## Examples

          iex> rank_in_future!(~D[1992-06-21], :unisex, "Colombia", {2, 6})
          %{country: "Colombia", dob: "1992-06-21", offset: "2y6m0d", rank: 23711438,
            sex: :unisex}
          iex> rank_in_future!(~D[1992-06-21], :random, "Colombia", {2, 6})
          ** (RuntimeError) random is an invalid value for the parameter "sex", valid values are: male, female, unisex

      """
      @spec rank_in_future!(Date.t, gender, String.t, offset) :: rank_with_offset | no_return
      def rank_in_future!(dob, gender, country, future_date) do
        Population.Rank.in_future!(dob, gender, country, future_date)
      end

      @doc """
      Calculates the day on which a person with the given date of birth, sex and
      country of origin has reached (or will reach) a certain world population rank.

      Returns `{:ok, ``t:date_by_rank/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> date_by_rank(~D[1992-06-21], :unisex, "Colombia", 1_000_000)
          {:ok,
           %{country: "Colombia", date_on_rank: "1993-07-29", dob: "1992-06-21",
             rank: 1000000, sex: :unisex}}
          iex> date_by_rank(~D[0600-06-21], :unisex, "Colombia", 1_000_000)
          {:error,
           "The birthdate 0600-06-21 can not be processed, only dates between 1920-01-01 and 2059-12-31 are supported"}

      """
      @spec date_by_rank(Date.t, gender, String.t, integer) :: {:ok, date_by_rank} | failure
      def date_by_rank(dob, gender, country, rank) do
        Population.Rank.date_by_rank(dob, gender, country, rank)
      end

      @doc """
      Calculates the day on which a person with the given date of birth, sex and
      country of origin has reached (or will reach) a certain world population rank.

      Returns `t:date_by_rank/0` if the call succeed, raises a `RuntimeError` with a
      message including the `reason`.

      ## Examples

          iex> date_by_rank!(~D[1992-06-21], :unisex, "Colombia", 1_000_000)
          %{country: "Colombia", date_on_rank: "1993-07-29", dob: "1992-06-21",
            rank: 1000000, sex: :unisex}
          iex> date_by_rank!(~D[0600-06-21], :unisex, "Colombia", 1_000_000)
          ** (RuntimeError) The birthdate 0600-06-21 can not be processed, only dates between 1920-01-01 and 2059-12-31 are supported

      """
      @spec date_by_rank!(Date.t, gender, String.t, integer) :: date_by_rank | no_return
      def date_by_rank!(dob, gender, country, rank) do
        Population.Rank.date_by_rank!(dob, gender, country, rank)
      end

      @doc """
      Retrieves the population table for all countries and a specific age group in
      the given year.

      Returns `{:ok, ``t:population_tables/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> tables(2014, 18)
          {:ok,
           [%{age: 18, country: "Afghanistan", females: 350820, males: 366763,
              total: 717583, year: 2014},
            %{age: 18, country: "Albania", females: 29633, males: 30478, total: 60111,
              year: 2014},
            ...]}
          iex> tables(2500, 18)
          {:error,
           "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

      """
      @spec tables(valid_year, valid_age) :: {:ok, population_tables} | failure
      def tables(year, age) do
        Population.Table.all(year, age)
      end

      @doc """
      Retrieves the population table for all countries and a specific age group in
      the given year.

      Returns `t:population_tables/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> tables!(2014, 18)
          [%{age: 18, country: "Afghanistan", females: 350820, males: 366763,
             total: 717583, year: 2014},
           %{age: 18, country: "Albania", females: 29633, males: 30478, total: 60111,
             year: 2014},
           ...]
          iex> tables!(2500, 18)
          ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

      """
      @spec tables!(valid_year, valid_age) :: population_tables | no_return
      def tables!(year, age) do
        Population.Table.all!(year, age)
      end

      @doc """
      Retrieves the population table for a specific age group in the given year and
      country.

      Returns `{:ok, ``t:population_table/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> table_by_country("Colombia", 2014, 18)
          {:ok,
           %{age: 18, country: "Colombia", females: 430971, males: 445096, total: 876067,
             year: 2014}}
          iex> table_by_country("Colombia", 2500, 18)
          {:error,
           "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

      """
      @spec table_by_country(String.t, valid_year, valid_age) :: {:ok, population_table} | failure
      def table_by_country(country, year, age) do
        Population.Table.by_country(country, year, age)
      end

      @doc """
      Retrieves the population table for a specific age group in the given year and
      country.

      Returns `t:population_table/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> table_by_country!("Colombia", 2014, 18)
          %{age: 18, country: "Colombia", females: 430971, males: 445096, total: 876067,
            year: 2014}
          iex> table_by_country!("Colombia", 2500, 18)
          ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

      """
      @spec table_by_country!(String.t, valid_year, valid_age) :: population_table | no_return
      def table_by_country!(country, year, age) do
        Population.Table.by_country!(country, year, age)
      end

      @doc """
      Retrieves the population tables for a given year and country. Returns tables
      for all ages from `0` to `100`.

      Returns `{:ok, ``t:population_tables/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> tables_for_all_ages_by_country("Colombia", 2014)
          {:ok,
           [%{age: 0, country: "Colombia", females: 432462, males: 452137, total: 884599,
              year: 2014},
            %{age: 1, country: "Colombia", females: 436180, males: 455621, total: 891802,
              year: 2014},
            ...]}
          iex> tables_for_all_ages_by_country("Colombia", 2500)
          {:error,
           "The year 2500 can not be processed, because only years between 1950 and 2100 are supported"}

      """
      @spec tables_for_all_ages_by_country(String.t, valid_year) :: {:ok, population_tables} | failure
      def tables_for_all_ages_by_country(country, year) do
        Population.Table.all_ages_by_country(country, year)
      end

      @doc """
      Retrieves the population tables for a given year and country. Returns tables
      for all ages from `0` to `100`.

      Returns `t:population_tables/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> tables_for_all_ages_by_country!("Colombia", 2014)
          [%{age: 0, country: "Colombia", females: 432462, males: 452137, total: 884599,
             year: 2014},
           %{age: 1, country: "Colombia", females: 436180, males: 455621, total: 891802,
             year: 2014},
           ...]
          iex> tables_for_all_ages_by_country!("Colombia", 2500)
          ** (RuntimeError) The year 2500 can not be processed, because only years between 1950 and 2100 are supported

      """
      @spec tables_for_all_ages_by_country!(String.t, valid_year) :: population_tables | no_return
      def tables_for_all_ages_by_country!(country, year) do
        Population.Table.all_ages_by_country!(country, year)
      end

      @doc """
      Retrieves the population tables for a specific age group in the given country.
      Returns tables for all years from `1950` to `2100`.

      Returns `{:ok, ``t:population_tables/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> tables_for_all_years_by_country("Colombia", 18)
          {:ok,
           [%{age: 18, country: "Colombia", females: 114873, males: 116249, total: 231122,
              year: 1950},
            %{age: 18, country: "Colombia", females: 116899, males: 118123, total: 235022,
              year: 1951},
            ...]}
          iex> tables_for_all_years_by_country("Colombia", 101)
          {:error,
           "The age 101 can not be processed, because only ages between 0 and 100 years are supported"}

      """
      @spec tables_for_all_years_by_country(String.t, valid_age) :: {:ok, population_tables} | failure
      def tables_for_all_years_by_country(country, age) do
        Population.Table.all_years_by_country(country, age)
      end

      @doc """
      Retrieves the population tables for a specific age group in the given country.
      Returns tables for all years from `1950` to `2100`.

      Returns `t:population_tables/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> tables_for_all_years_by_country!("Colombia", 18)
          [%{age: 18, country: "Colombia", females: 114873, males: 116249, total: 231122,
             year: 1950},
           %{age: 18, country: "Colombia", females: 116899, males: 118123, total: 235022,
             year: 1951},
           ...]
          iex> tables_for_all_years_by_country!("Colombia", 101)
          ** (RuntimeError) The age 101 can not be processed, because only ages between 0 and 100 years are supported

      """
      @spec tables_for_all_years_by_country!(String.t, valid_age) :: population_tables | no_return
      def tables_for_all_years_by_country!(country, age) do
        Population.Table.all_years_by_country!(country, age)
      end

      @doc """
      Determines total population for a given country on a given date.
      Valid dates are `2013-01-01` to `2022-12-31`.

      Returns `{:ok, ``t:total_population/0``}` if the call succeed, otherwise `{:error, reason}`.

      ## Examples

          iex> table_for_country_by_date("Colombia", ~D[2016-12-10])
          {:ok, %{date: "2016-12-10", population: 50377885}}
          iex> table_for_country_by_date("Colombia", ~D[2012-12-10])
          {:error,
           "The calculation date 2012-12-10 can not be processed, only dates between 2013-01-01 and 2022-12-31 are supported"}

      """
      @spec table_for_country_by_date(String.t, Date.t) :: {:ok, population_table} | failure
      def table_for_country_by_date(country, date) do
        Population.Table.for_country_by_date(country, date)
      end

      @doc """
      Determines total population for a given country on a given date.
      Valid dates are `2013-01-01` to `2022-12-31`.

      Returns `t:total_population/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> table_for_country_by_date!("Colombia", ~D[2016-12-10])
          %{date: "2016-12-10", population: 50377885}
          iex> table_for_country_by_date!("Colombia", ~D[2012-12-10])
          ** (RuntimeError) The calculation date 2012-12-10 can not be processed, only dates between 2013-01-01 and 2022-12-31 are supported

      """
      @spec table_for_country_by_date!(String.t, Date.t) :: population_table | no_return
      def table_for_country_by_date!(country, date) do
        Population.Table.for_country_by_date!(country, date)
      end

      @doc """
      Determines total population for a given country with separate results for
      `today` and `tomorrow`.

      Returns `{:ok, ``t:population_contrast/0``}` if the call succeed, otherwise
      `{:error, reason}`.

      ## Examples

          iex> tables_for_today_and_tomorrow_by_country("Colombia")
          {:ok,
           %{today: %{date: "2016-12-11", population: 50379477},
             tomorrow: %{date: "2016-12-12", population: 50381070}}}
          iex> tables_for_today_and_tomorrow_by_country("Pluton")
          {:error,
           "Pluton is an invalid value for the parameter \"country\", the list of valid values can be retrieved from the endpoint /countries"}

      """
      @spec tables_for_today_and_tomorrow_by_country(String.t) :: {:ok, population_contrast} | failure
      def tables_for_today_and_tomorrow_by_country(country) do
        Population.Table.for_today_and_tomorrow_by_country(country)
      end

      @doc """
      Determines total population for a given country with separate results for
      `today` and `tomorrow`.

      Returns `t:population_contrast/0` if the call succeed, otherwise raises a
      `RuntimeError` with a message including the `reason`.

      ## Examples

          iex> tables_for_today_and_tomorrow_by_country!("Colombia")
          %{today: %{date: "2016-12-11", population: 50379477},
            tomorrow: %{date: "2016-12-12", population: 50381070}}
          iex> tables_for_today_and_tomorrow_by_country!("Pluton")
          ** (RuntimeError) Pluton is an invalid value for the parameter "country", the list of valid values can be retrieved from the endpoint /countries

      """
      @spec tables_for_today_and_tomorrow_by_country!(String.t) ::  population_contrast | no_return
      def tables_for_today_and_tomorrow_by_country!(country) do
        Population.Table.for_today_and_tomorrow_by_country!(country)
      end
    end
  end
end
