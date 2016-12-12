defmodule WorldPopulationRankToday do
  @moduledoc false
  @fields [:dob, :sex, :country, :rank]
  defstruct @fields
end

defmodule WorldPopulationRankByDate do
  @moduledoc false
  @fields [:dob, :sex, :country, :rank, :date]
  defstruct @fields
end

defmodule WorldPopulationRankByAge do
  @moduledoc false
  @fields [:dob, :sex, :country, :rank, :age]
  defstruct @fields
end

defmodule WorldPopulationRankWithOffset do
  @moduledoc false
  @fields [:dob, :sex, :country, :rank, :offset]
  defstruct @fields
end

defmodule DateByWorldPopulationRank do
  @moduledoc false
  @fields [:dob, :sex, :country, :rank, :date_on_rank]
  defstruct @fields
end

defmodule RemainingLifeExpectancy do
  @moduledoc false
  @fields [:sex, :country, :date, :age, :remainig_life_expectancy]
  defstruct @fields
end

defmodule TotalLifeExpectancy do
  @moduledoc false
  @fields [:sex, :country, :dob, :total_life_expectancy]
  defstruct @fields
end

defmodule PopulationTable do
  @moduledoc false
  @fields [:total, :females, :males, :year, :age]
  defstruct @fields
end

defmodule TotalPopulation do
  @moduledoc false
  @fields [:date, :population]
  defstruct @fields
end

defmodule MortalityDistribution do
  @moduledoc false
  @fields [:age, :mortality_precent]
  defstruct @fields
end
