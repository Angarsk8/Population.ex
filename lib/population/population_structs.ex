defmodule WorldPopulationRankToday do
  @fields [:dob, :gender, :country, :rank]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankByDate do
  @fields [:dob, :gender, :country, :rank, :date]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankByAge do
  @fields [:dob, :gender, :country, :rank, :age]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankWithOffset do
  @fields [:dob, :gender, :country, :rank, :offset]
  @enforce_keys @fields
  defstruct @fields
end

defmodule DateByWorldPopulationRank do
  @fields [:dob, :gender, :country, :rank, :date_on_rank]
  @enforce_keys @fields
  defstruct @fields
end

defmodule RemaininLifeExpectancy do
  @fields [:gender, :country, :date, :age, :remainig_life_expectancy]
  @enforce_keys @fields
  defstruct @fields
end

defmodule TotalLifeExpectancy do
  @fields [:gender, :country, :dob, :total_life_expectancy]
  @enforce_keys @fields
  defstruct @fields
end

defmodule PopulationTable do
  @fields [:total, :females, :males, :year, :age]
  @enforce_keys @fields
  defstruct @fields
end

defmodule TotalPopulation do
  @fields [:date, :population]
  @enforce_keys @fields
  defstruct @fields
end

defmodule MortalityDistribution do
  @fields [:age, :mortality_precent]
  @enforce_keys @fields
  defstruct @fields
end
