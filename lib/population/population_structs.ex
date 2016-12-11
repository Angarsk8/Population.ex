defmodule WorldPopulationRankToday do
  @moduledoc false
  @fields [:dob, :gender, :country, :rank]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankByDate do
  @moduledoc false
  @fields [:dob, :gender, :country, :rank, :date]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankByAge do
  @moduledoc false
  @fields [:dob, :gender, :country, :rank, :age]
  @enforce_keys @fields
  defstruct @fields
end

defmodule WorldPopulationRankWithOffset do
  @moduledoc false
  @fields [:dob, :gender, :country, :rank, :offset]
  @enforce_keys @fields
  defstruct @fields
end

defmodule DateByWorldPopulationRank do
  @moduledoc false
  @fields [:dob, :gender, :country, :rank, :date_on_rank]
  @enforce_keys @fields
  defstruct @fields
end

defmodule RemaininLifeExpectancy do
  @moduledoc false
  @fields [:gender, :country, :date, :age, :remainig_life_expectancy]
  @enforce_keys @fields
  defstruct @fields
end

defmodule TotalLifeExpectancy do
  @moduledoc false
  @fields [:gender, :country, :dob, :total_life_expectancy]
  @enforce_keys @fields
  defstruct @fields
end

defmodule PopulationTable do
  @moduledoc false
  @fields [:total, :females, :males, :year, :age]
  @enforce_keys @fields
  defstruct @fields
end

defmodule TotalPopulation do
  @moduledoc false
  @fields [:date, :population]
  @enforce_keys @fields
  defstruct @fields
end

defmodule MortalityDistribution do
  @moduledoc false
  @fields [:age, :mortality_precent]
  @enforce_keys @fields
  defstruct @fields
end
