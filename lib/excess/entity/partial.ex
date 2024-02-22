defmodule Excess.Entity.Partial do
  @moduledoc """
  Contains a partially loaded `Excess.Entity` in a `Excess.Runtime`.
  """

  defstruct [:id, loaded: [], components: %{}]
  @type t :: %__MODULE__{id: any(), loaded: list(), components: map()}

  def new(id, loaded, components) do
    %__MODULE__{
      id: id,
      loaded: loaded,
      components: components
    }
  end
end
