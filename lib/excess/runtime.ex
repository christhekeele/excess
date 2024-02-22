defmodule Excess.Runtime do
  require Logger
  require Matcha

  defstruct [:id, :table, :id_generator]
  @type t :: %__MODULE__{id: any(), table: :ets.table(), id_generator: (-> any())}

  ####
  # RUNTIMES
  ##

  def new(opts \\ []) do
    {table, opts} = Keyword.pop(opts, :table, nil)

    table =
      if table do
        table
      else
        :ets.new(__MODULE__, [:set, :public, write_concurrency: :auto, read_concurrency: true])
      end

    {id_generator, opts} = Keyword.pop(opts, :id_generator, &make_ref/0)

    unless opts == [] do
      raise "unexpected options: `#{inspect(opts)}`"
    end

    %__MODULE__{id: UUID.uuid4(), table: table, id_generator: id_generator}
  end

  def make_id(runtime = %__MODULE__{}) do
    runtime.id_generator.()
  end

  ####
  # SYSTEMS
  ##

  def start_system(runtime = %__MODULE__{}, system_module, state \\ nil) do
    system = Excess.System.new(runtime, state)
    Excess.System.start_link(system_module, system)
  end

  def systems(runtime = %__MODULE__{}) do
    Excess.System.Registry.list(runtime.id)
  end

  ####
  # EVENTS
  ##

  def broadcast_event(runtime = %__MODULE__{}, event) do
    Logger.debug(
      "RUNTIME BROADCASTING EVENT `#{inspect(event)}` for runtime: #{inspect(runtime)}"
    )

    for {pid, _system} <- Excess.System.Registry.list(runtime.id) do
      GenServer.cast(pid, {:event, event})
    end

    :ok
  end

  ####
  # ENTITIES
  ##

  defp components_to_object(runtime = %__MODULE__{}, components) do
    Map.pop_lazy(components, :id, runtime.id_generator)
  end

  defp components_to_entity(runtime = %__MODULE__{}, components) do
    object = components_to_object(runtime, components)
    object_to_entity(runtime, object)
  end

  defp entity_to_object(_runtime = %__MODULE__{}, entity = %Excess.Entity{}) do
    {entity.id, entity.components}
  end

  defp object_to_entity(_runtime = %__MODULE__{}, {id, components}) do
    Excess.Entity.new(id, components)
  end

  defp insert_objects(runtime = %__MODULE__{}, objects) when is_list(objects) do
    :ets.insert(runtime.table, objects) && :ok
  end

  @doc section: :entities
  @doc """
  Inserts multiple `things` into a `runtime`.

  Each thing can be a fully specified `Excess.Entity` or a simple map of components.
  For convenience, if the component map has a key called `:id` it will be extracted and used
  as the entity id; otherwise it will be given one by calling `Excess.Runtime.make_id/1`.

  Any existing entity will have its current components fully replaced.
  See `update/2` for a less destructive operation.
  """
  @spec insert(runtime :: t(), things) :: :ok
        when things: [Excess.Entity.t() | map()]
  def insert(runtime, things)

  def insert(runtime = %__MODULE__{}, things) when is_list(things) do
    entities =
      Enum.map(things, fn
        entity = %Excess.Entity{} -> entity
        components = %{} -> components_to_entity(runtime, components)
      end)

    objects = Enum.map(entities, &entity_to_object(runtime, &1))

    :ok = insert_objects(runtime, objects)

    {:ok, entities}
  end

  def entity(runtime = %__MODULE__{}) do
    %Excess.Entity.Reference{id: make_id(runtime), runtime: runtime}
  end

  def entity(runtime = %__MODULE__{}, entity = %Excess.Entity.Reference{}) do
    %Excess.Entity.Reference{id: entity.id, runtime: runtime}
  end

  def entity(runtime = %__MODULE__{}, entity = %Excess.Entity{}) do
    %Excess.Entity.Reference{id: entity.id, runtime: runtime}
  end

  def entity(runtime = %__MODULE__{}, id) do
    %Excess.Entity.Reference{id: id, runtime: runtime}
  end

  def update(runtime = %__MODULE__{}, entity = %Excess.Entity{}) do
    :ets.insert(runtime.table, [{entity.id, entity.components}])
    {:ok, entity}
  end

  def remove_entity(runtime, entity = %Excess.Entity.Reference{}) do
    remove_entity(runtime, entity.id)
  end

  def remove_entity(runtime, id) do
    true = :ets.delete(runtime.table, id)
    :ok
  end

  def filter_entities(runtime = %__MODULE__{}, filter = %Matcha.Spec{}) do
    runtime.table
    |> Matcha.Table.ETS.Select.all(filter)
  end

  def remove_entities(runtime, filter) do
    for entity <- filter_entities(runtime, filter) do
      remove_entity(runtime, entity.id)
    end
  end

  def entities(runtime) do
    spec =
      Matcha.spec :table do
        {id, components} ->
          %Excess.Entity{
            id: id,
            components: components
          }
      end

    runtime.table
    |> Matcha.Table.ETS.Select.all(spec)

    # |> Enum.map(&put_in(&1.runtime, runtime))
  end

  ####
  # ACCESS PROTOCOL
  ###

  @behaviour Access

  @impl Access
  @doc """
       Fetches the `entity` of the given `runtime`.

       For more information, see the [`Access.fetch/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:fetch/2).
       """ || false
  def fetch(entity = %__MODULE__{}, component) do
    Excess.Runtime.Access.fetch(entity, component)
  end

  @impl Access
  @doc """
       Pops the `entity` out of the given `runtime`.

       For more information, see the [`Access.pop/2` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:pop/2).
       """ || false
  def pop(entity = %__MODULE__{}, component) do
    Excess.Runtime.Access.pop(entity, component)
  end

  @impl Access
  @doc """
       Gets and updates the `entity` of the given `runtime` using the provided `function`.

       For more information, see the [`Access.get_and_update/3` docs](https://hexdocs.pm/elixir/1.12.3/Access.html#c:get_and_update/3).
       """ || false
  def get_and_update(entity = %__MODULE__{}, component, function) do
    Excess.Runtime.Access.get_and_update(entity, component, function)
  end
end
