# Population

Elixir OTP application library for the [World Population API](http://api.population.io/).

## Public API

See the full online documentation [here](https://hexdocs.pm/population/Population.html#summary).

### Countries: list available countries

* [countries/0](https://hexdocs.pm/population/Population.html#countries/0)
* [countries!/0](https://hexdocs.pm/population/Population.html#countries!/0)

### Life Expectancy: calculate life expectancy

* [remaining_life_expectancy/4](https://hexdocs.pm/population/Population.html#remaining_life_expectancy/4)
* [remaining_life_expectancy!/4](https://hexdocs.pm/population/Population.html#remaining_life_expectancy!/4)
* [total_life_expectancy/3](https://hexdocs.pm/population/Population.html#total_life_expectancy/3)
* [total_life_expectancy!/3](https://hexdocs.pm/population/Population.html#total_life_expectancy!/3)

### Mortality Distribution: retrieve mortality distribution tables

* [mortality_distribution/3](https://hexdocs.pm/population/Population.html#mortality_distribution/3)
* [mortality_distribution!/3](https://hexdocs.pm/population/Population.html#mortality_distribution!/3)

### World Population Rank: determine world population rank

* [rank_today/3](https://hexdocs.pm/population/Population.html#rank_today/3)
* [rank_today!/3](https://hexdocs.pm/population/Population.html#rank_today!/3)
* [rank_by_date/4](https://hexdocs.pm/population/Population.html#rank_by_date/4)
* [rank_by_date!/4](https://hexdocs.pm/population/Population.html#rank_by_date!/4)
* [rank_by_age/4](https://hexdocs.pm/population/Population.html#rank_by_age/4)
* [rank_by_age!/4](https://hexdocs.pm/population/Population.html#rank_by_age!/4)
* [rank_in_past/4](https://hexdocs.pm/population/Population.html#rank_in_past/4)
* [rank_in_past!/4](https://hexdocs.pm/population/Population.html#rank_in_past!/4)
* [rank_in_future/4](https://hexdocs.pm/population/Population.html#rank_in_future/4)
* [rank_in_future!/4](https://hexdocs.pm/population/Population.html#rank_in_future!/4)
* [date_by_rank/4](https://hexdocs.pm/population/Population.html#date_by_rank/4)
* [date_by_rank!/4](https://hexdocs.pm/population/Population.html#date_by_rank!/4)

### Population : retrieve population tables

* [tables/2](https://hexdocs.pm/population/Population.html#tables/2)
* [tables!/2](https://hexdocs.pm/population/Population.html#tables!/2)
* [table_by_country/3](https://hexdocs.pm/population/Population.html#table_by_country/3)
* [table_by_country!/3](https://hexdocs.pm/population/Population.html#table_by_country!/3)
* [tables_for_all_ages_by_country/2](https://hexdocs.pm/population/Population.html#tables_for_all_ages_by_country/2)
* [tables_for_all_ages_by_country!/2](https://hexdocs.pm/population/Population.html#tables_for_all_ages_by_country!/2)
* [tables_for_all_years_by_country/2](https://hexdocs.pm/population/Population.html#tables_for_all_years_by_country/2)
* [tables_for_all_years_by_country!/2](https://hexdocs.pm/population/Population.html#tables_for_all_years_by_country!/2)
* [table_for_country_by_date/2](https://hexdocs.pm/population/Population.html#table_for_country_by_date/2)
* [table_for_country_by_date!/2](https://hexdocs.pm/population/Population.html#table_for_country_by_date!/2)
* [tables_for_today_and_tomorrow_by_country/1](https://hexdocs.pm/population/Population.html#tables_for_today_and_tomorrow_by_country/1)
* [tables_for_today_and_tomorrow_by_country!/1](https://hexdocs.pm/population/Population.html#tables_for_today_and_tomorrow_by_country!/1)


## Installation

  1. Add `population` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:population, "~> 0.1.0"}]
    end
    ```

  2. Ensure `population` is started before your application:

    ```elixir
    def application do
      [applications: [:population]]
    end
    ```
