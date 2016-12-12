defmodule Population.Mixfile do
  use Mix.Project

  def project do
    [app: :population,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "Population",
     source_url: "https://github.com/Angarsk8/population.ex",
     description: description(),
     docs: [main: "Population"],
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Population, []},
     registered: [
        Population.Country,
        Population.LifeExpectancy,
        Population.Mortality,
        Population.Rank,
        Population.Table
      ]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.10.0"},
      {:json, "~> 1.0"},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp description do
    """
    Elixir OTP application library for the [World Population API](http://api.population.io/)
    """
  end

  defp package do
    [
     name: :population,
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Andrés García"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/Angarsk8/population.ex",
              "Docs" => "https://hexdocs.pm/population/api-reference.html"}]
  end
end
