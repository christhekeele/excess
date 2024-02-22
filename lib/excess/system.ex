defmodule Excess.System do
  @moduledoc """
  The basic unit of behaviour and concurrency in Excess.

  An `Excess.System` is a group of related event handlers.
  Each system can only handle one event at a time; different systems will process events in parallel.
  As such, it is useful to handle events that might otherwise interfere with each other in the same system.
  """

  defstruct [:id, :runtime, :state]

  @callback handle_event(event :: any(), system :: %__MODULE__{}) ::
              {result :: any(), system :: %__MODULE__{}}

  def new(runtime, state \\ nil) do
    %__MODULE__{
      id: UUID.uuid4(),
      runtime: runtime,
      state: state
    }
  end

  def start_link(system_module, system, opts \\ []) do
    GenServer.start_link(system_module, system, opts)
  end

  def call(system, event) do
  end

  defmacro __using__(_opts \\ []) do
    quote do
      use GenServer
      @behaviour Excess.System

      def start_link(system = %Excess.System{}) do
        GenServer.start_link(__MODULE__, system)
      end

      def init(system = %Excess.System{}) do
        Excess.System.Registry.register(system.runtime.id, __MODULE__)
        {:ok, system}
      end

      def handle_call({:event, event}, from, system = %Excess.System{}) do
        {result, system = %Excess.System{}} = handle_event(event, system)
        {:reply, result, system}
      end

      def handle_cast({:event, event}, system = %Excess.System{}) do
        {_result, system = %Excess.System{}} = handle_event(event, system)
        {:noreply, system}
      end

      def handle_event(_event, system) do
        {:ok, system}
      end

      defoverridable init: 1, handle_event: 2
    end
  end
end

defmodule Excess.System.Set do
  @moduledoc false

  def process(event), do: event
end

defmodule Excess.System.Sequence do
  @moduledoc false

  def process(event), do: event
end
