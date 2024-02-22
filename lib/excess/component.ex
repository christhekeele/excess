defmodule Excess.Component do
  defmacro __using__(struct \\ []) do
    quote do
      defstruct unquote(struct)

      @behaviour Access

      @impl Access
      @doc """
      Fetches the `field` of the given `component`.

      For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
      """
      def fetch(component = %__MODULE__{}, field) do
        Excess.Component.Access.fetch(component, field)
      end

      @impl Access
      @doc """
      Gets and updates the `field` of the given `component` using the provided `function`.

      For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
      """
      def get_and_update(component = %__MODULE__{}, field, func) do
        Excess.Component.Access.get_and_update(component, field, func)
      end

      @impl Access
      @doc """
      Pops the `field` out of the given `component`.

      For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
      """
      def pop(component = %__MODULE__{}, field) do
        Excess.Component.Access.pop(component, field)
      end
    end
  end
end
