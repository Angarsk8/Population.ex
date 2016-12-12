defmodule Population do

  @moduledoc """
  Elixir OTP application library for the [World Population API](http://api.population.io/)

  ## Public API

  ### Countries: list available countries

  * [countries/0](#countries/0)
  * [countries!/0](#countries!/0)

  ### Life Expectancy: calculate life expectancy

  * [remaining_life_expectancy/4](#remaining_life_expectancy/4)
  * [remaining_life_expectancy!/4](#remaining_life_expectancy!/4)
  * [total_life_expectancy/3](#total_life_expectancy/3)
  * [total_life_expectancy!/3](#total_life_expectancy!/3)

  ### Mortality Distribution: retrieve mortality distribution tables

  * [mortality_distribution/3](#mortality_distribution/3)
  * [mortality_distribution!/3](#mortality_distribution!/3)

  ### World Population Rank: determine world population rank

  * [rank_today/3](#rank_today/3)
  * [rank_today!/3](#rank_today!/3)
  * [rank_by_date/4](#rank_by_date/4)
  * [rank_by_date!/4](#rank_by_date!/4)
  * [rank_by_age/4](#rank_by_age/4)
  * [rank_by_age!/4](#rank_by_age!/4)
  * [rank_in_past/4](#rank_in_past/4)
  * [rank_in_past!/4](#rank_in_past!/4)
  * [rank_in_future/4](#rank_in_future/4)
  * [rank_in_future!/4](#rank_in_future!/4)
  * [date_by_rank/4](#date_by_rank/4)
  * [date_by_rank!/4](#date_by_rank!/4)

  ### Population : retrieve population tables

  * [tables/2](#tables/2)
  * [tables!/2](#tables!/2)
  * [table_by_country/3](#table_by_country/3)
  * [table_by_country!/3](#table_by_country!/3)
  * [tables_for_all_ages_by_country/2](#tables_for_all_ages_by_country/2)
  * [tables_for_all_ages_by_country!/2](#tables_for_all_ages_by_country!/2)
  * [tables_for_all_years_by_country/2](#tables_for_all_years_by_country/2)
  * [tables_for_all_years_by_country!/2](#tables_for_all_years_by_country!/2)
  * [table_for_country_by_date/2](#table_for_country_by_date/2)
  * [table_for_country_by_date!/2](#table_for_country_by_date!/2)
  * [tables_for_today_and_tomorrow_by_country/1](#tables_for_today_and_tomorrow_by_country/1)
  * [tables_for_today_and_tomorrow_by_country!/1](#tables_for_today_and_tomorrow_by_country!/1)

  """

  use Application
  use Population.Base

  @doc false
  def start(_start_type, _start_args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Population.Country, [[]]),
      worker(Population.Rank, [%{}]),
      worker(Population.LifeExpectancy, [%{}]),
      worker(Population.Table, [[]]),
      worker(Population.Mortality, [[]])
    ]

    options = [strategy: :one_for_one, name: Population.Supervisor]
    Supervisor.start_link(children, options)
  end
end
