defmodule Population do
  use Application

  def start(_start_type, _start_args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Population.Country, [[]]),
      worker(Population.Rank, [%{}]),
      worker(Population.LifeExpectancy, [%{}]),
    ]

    options = [strategy: :one_for_one, name: Population.Supervisor]
    Supervisor.start_link(children, options)
  end
end
