defmodule Excess.Entity.Reference.Access do
  @behaviour Access

  @impl Access
  @doc """
  Fetches the `component` of the given `entity`.

  For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
  """
  def fetch(entity = %Excess.Entity.Reference{}, component) do
    components = Excess.Entity.components(entity)
    Map.fetch(components, component)
  end

  @impl Access
  @doc """
  Pops the `component` out of the given `entity`.

  For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
  """
  def pop(entity = %Excess.Entity.Reference{runtime: runtime}, component) do
    components = Excess.Entity.components(entity)

    {component_value, new_components} = Map.pop(components, component)

    :ets.update_element(runtime.table, entity.id, [
      {2, new_components}
    ])

    {component_value,
     %Excess.Entity{
       id: entity.id,
       components: new_components
     }}
  end

  @impl Access
  @doc """
  Gets and updates the `component` of the given `entity` using the provided `function`.

  For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
  """
  def get_and_update(entity = %Excess.Entity.Reference{runtime: runtime}, component, function) do
    current_components = Excess.Entity.components(entity)

    current_component_value =
      case Map.fetch(current_components, component) do
        {:ok, component_value} -> component_value
        :error -> nil
      end

    case function.(current_component_value) do
      {current_component_value, new_component_value} ->
        new_components = Map.put(current_components, component, new_component_value)

        :ets.update_element(runtime.table, entity.id, [
          {2, new_components}
        ])

        {current_component_value,
         %Excess.Entity{
           id: entity.id,
           components: new_components
         }}

      :pop ->
        new_components = Map.delete(current_components, component)

        :ets.update_element(runtime.table, entity.id, [
          {2, new_components}
        ])

        {current_component_value,
         %Excess.Entity{
           id: entity.id,
           components: new_components
         }}
    end
  end
end
