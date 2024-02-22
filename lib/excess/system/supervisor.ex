defmodule Excess.System.Supervisor do
  @moduledoc false


  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(system, state) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {system, state}
    )
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
