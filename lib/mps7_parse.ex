defmodule Mps7Parse do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Mps7Parse.Parser, [])
    ]

    opts = [strategy: :one_for_one, name: Mps7Parse]
    Supervisor.start_link(children, opts)
  end
end
