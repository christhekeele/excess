defmodule Excess.Entity do
  @moduledoc """
  The basic unit of data in an `Excess.Runtime`.
  """
  require Matcha

  @default_components %{}

  defstruct [:id, components: @default_components]
  @type t :: %__MODULE__{id: any(), components: map()}

  def new(id, components \\ @default_components) do
    %__MODULE__{
      id: id,
      components: components
    }
  end

  defmacro filter(filter) do
    {match, guards} = :elixir_utils.extract_guards(filter)
    pattern = quote(do: {id, components = unquote(match)})

    head =
      for guard <- guards, reduce: pattern do
        head -> {:when, [], [head, guard]}
      end

    quote location: :keep do
      require Matcha

      Matcha.spec :table do
        unquote(head) ->
          %Excess.Entity{
            id: id,
            components: components
          }
      end
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
    Excess.Entity.Access.fetch(entity, component)
  end

  @impl Access
  @doc """
       Pops the `component` out of the given `entity`.

       For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
       """ || false
  def pop(entity = %__MODULE__{}, component) do
    Excess.Entity.Access.pop(entity, component)
  end

  @impl Access
  @doc """
       Gets and updates the `component` of the given `entity` using the provided `function`.

       For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
       """ || false
  def get_and_update(entity = %__MODULE__{}, component, function) do
    Excess.Entity.Access.get_and_update(entity, component, function)
  end
end
