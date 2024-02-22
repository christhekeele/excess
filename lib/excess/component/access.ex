defmodule Excess.Component.Access do
  @behaviour Access

  @impl Access
  @doc """
  Fetches the `field` of the given `component`.

  For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
  """
  def fetch(component, field) do
    Map.fetch(component, field)
  end

  @impl Access
  @spec pop(map(), any()) :: {any(), map()}
  @doc """
  Pops the `field` out of the given `component`.

  For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
  """
  def pop(component, field) do
    Map.pop(component, field)
  end

  @impl Access
  @doc """
  Gets and updates the `field` of the given `component` using the provided `function`.

  For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
  """
  def get_and_update(component, field, function) do
    Map.get_and_update(component, field, function)
  end
end
