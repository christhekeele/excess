defmodule Excess.Application do
  @moduledoc false


  use Application

  @impl true
  def start(_type, _args) do
    [
      Excess.System.Registry,
      Excess.System.Supervisor
    ]
    |> Supervisor.start_link(
      strategy: :rest_for_one,
      name: __MODULE__.Supervisor
    )
  end
end
