defmodule Excess.Entity.Reference do
  @moduledoc """
  Contains a (weak) unloaded reference to an `Excess.Entity` in a `Excess.Runtime`.

  Used by the framework for selectively/lazily loading components of an entity.
  """

  defstruct [:id, :runtime]
  @type t :: %__MODULE__{id: any(), runtime: Excess.Runtime.t()}

  @doc """
  Returns a fully loaded `Excess.Entity` containing the current state of all components.
  """
  def load(reference = %__MODULE__{id: id}) do
    case :ets.lookup(reference.runtime.table, id) do
      [{^id, components}] ->
        {:ok, Excess.Entity.new(id, components)}

      [] ->
        :error
    end
  end

  @doc """
  Returns a partially loaded `Excess.Entity.Partial` containing the current state of provided `components`.
  """
  def load(reference = %__MODULE__{id: id}, components)
      when is_list(components) do
    load_components =
      components
      |> Enum.with_index(&{&1, :"$#{&2 + 2}"})
      |> Map.new()

    match_spec = [
      {
        {id, load_components},
        [],
        [
          {{id, load_components}}
        ]
      }
    ]

    case :ets.select(reference.runtime.table, match_spec) do
      [{^id, loaded_components}] ->
        {:ok,
         %Excess.Entity.Partial{
           id: id,
           loaded: components,
           components: loaded_components
         }}

      [] ->
        :error
    end
  end

  ####
  # ACCESS PROTOCOL
  ###

  @behaviour Access

  @impl Access
  @doc """
       Fetches the `component` of the given `entity`.

       For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
       """ || false
  def fetch(entity = %__MODULE__{}, component) do
    Excess.Entity.Reference.Access.fetch(entity, component)
  end

  @impl Access
  @doc """
       Pops the `component` out of the given `entity`.

       For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
       """ || false
  def pop(entity = %__MODULE__{}, component) do
    Excess.Entity.Reference.Access.pop(entity, component)
  end

  @impl Access
  @doc """
       Gets and updates the `component` of the given `entity` using the provided `function`.

       For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
       """ || false
  def get_and_update(entity = %__MODULE__{}, component, function) do
    Excess.Entity.Reference.Access.get_and_update(entity, component, function)
  end
end
