defmodule Excess.Entity.Access do
  @behaviour Access

  @impl Access
  @doc """
  Fetches the `component` of the given `entity`.

  For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
  """
  def fetch(entity = %Excess.Entity{}, component) do
    Map.fetch(entity.components, component)
  end

  @impl Access
  @doc """
  Pops the `component` out of the given `entity`.

  For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
  """
  def pop(entity = %Excess.Entity{}, component) do
    {value, components} = Map.pop(entity.components, component)
    {value, %{entity | components: components}}
  end

  @impl Access
  @doc """
  Gets and updates the `component` of the given `entity` using the provided `function`.

  For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
  """
  def get_and_update(entity = %Excess.Entity{}, component, function) do
    {value, components} = Map.get_and_update(entity.components, component, function)
    {value, %{entity | components: components}}
  end
end
