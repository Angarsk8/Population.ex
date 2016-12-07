defmodule Population do
  use Application

  def start(_start_type, _start_args) do
    import Supervisor.Spec

    children = [
      worker(Population.Country, [[]]),
      worker(Population.Rank, [%{}]),
    ]

    options = [name: Population.Supervisor, strategy: :one_for_one]
    Supervisor.start_link(children, options)
  end
end
