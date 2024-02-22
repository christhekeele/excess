defmodule Excess.Runtime.Access do
  @behaviour Access

  @impl Access
  @doc """
  Fetches the entity from `runtime` with the given `id`.

  For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
  """
  def fetch(runtime = %Excess.Runtime{}, id) do
    case :ets.lookup(runtime.table, id) do
      [{^id, components}] ->
        {:ok,
         %Excess.Entity{
           id: id,
           components: components
         }}

      [] ->
        :error
    end
  end

  @impl Access
  @doc """
  Pops the entity from `runtime` with the given `id`.

  If no entity is found, returns `default`.

  For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
  """
  def pop(runtime = %Excess.Runtime{}, id, default \\ nil) do
    case fetch(runtime, id) do
      {:ok, entity = %Excess.Entity{}} ->
        :ok = Excess.Runtime.remove_entity(runtime, id)
        {entity, runtime}

      :error ->
        {default, runtime}
    end
  end

  @impl Access
  @doc """
  Gets and updates the entity from `runtime` with the given `id` using the provided `function`.

  For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
  """
  def get_and_update(runtime = %Excess.Runtime{}, id, function) do
    current_entity =
      case fetch(runtime, id) do
        {:ok, entity = %Excess.Entity{}} ->
          entity

        :error ->
          nil
      end

    case function.(current_entity) do
      {^current_entity, new_entity} ->
        if current_entity.components != new_entity.components do
          :ets.update_element(runtime.table, id, [
            {2, new_entity.components}
          ])
        end

        {current_entity, runtime}

      :pop ->
        pop(runtime, id)
    end
  end
end
