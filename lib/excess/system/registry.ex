# TODO: make distributed-friendly with Horde, pogo?
defmodule Excess.System.Registry do
  @moduledoc false

  def child_spec(options \\ []) do
    options
    |> Keyword.merge(keys: :duplicate, name: __MODULE__)
    |> Registry.child_spec()
  end

  def start_link(options \\ []) do
    options
    |> Keyword.merge(keys: :duplicate, name: __MODULE__)
    |> Registry.start_link()
  end

  def list(runtime_id) do
    for {pid, {system_module, _groups}} <- Registry.lookup(__MODULE__, runtime_id) do
      {pid, system_module}
    end
  end

  def register(runtime_id, system_module, groups \\ []) do
    Registry.register(__MODULE__, runtime_id, {system_module, groups})
  end
end
