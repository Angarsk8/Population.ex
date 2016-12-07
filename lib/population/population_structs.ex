defmodule WorldPopulationRankToday do
  defstruct dob: "", gender: "", country: "", rank: 0
end

defmodule WorldPopulationRankByDate do
  defstruct dob: "", gender: "", country: "", rank: 0, date: ""
end

defmodule WorldPopulationRankByAge do
  defstruct dob: "", gender: "", country: "", rank: 0, age: ""
end

defmodule WorldPopulationRankWithOffset do
  defstruct dob: "", gender: "", country: "", rank: 0, offset: ""
end

defmodule DateByWorldPopulationRank do
  defstruct dob: "", gender: "", country: "", rank: 0, date_on_rank: ""
end

defmodule RemaininLifeExpectancy do
  defstruct gender: "", country: "", date: "", age: "", remainig_life_expectancy: 0.0
end

defmodule TotalLifeExpectancy do
  defstruct gender: "", country: "", dob: "", total_life_expectancy: 0.0
end

defmodule PopulationTable do
  defstruct total: 0, females: 0, males: 0, year: 0, age: 0
end

defmodule TotalPopulation do
  defstruct date: "", opulation: 0
end

defmodule TotalPopulation do
  defstruct date: "", opulation: 0
end

defmodule MortalityDistribution do
  defstruct age: 0, mortality_precent: 0.0
end
