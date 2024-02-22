# Excess

> **_An Elixir Component-Entity-System Simulation framework_**

## Synopsis

Excess is [CES](http://entity-systems.wikidot.com/) framework for state management of long-lived simulations with dynamic behaviour through data-oriented composition.

Excess strives to take full advantage of BEAM VM features, OTP tooling, and Elixir abstractions:

- Components
  - can be any erlang term, including scalars, enumerables, structs, pids, etc
  - can be added to entities multiple times (under different keys)
- Entities
  - are composed of key-value maps of components
  - are stored in ETS
  - can be filtered and queried by native pattern matching and guards
  - implement the access protocol for simple component fetching
  - use the repository pattern for standard functional updates
- Systems
  - are standard event-driven GenServer processes
  - can be dynamically registered and started
  - can be instantiated multiple times
- Runtimes
  - can be instanced

## Alternatives

- [Ecspanse](https://hexdocs.pm/ecspanse)

  - Components
    - are restricted to structs
    - are stored seperately in different tables

- [ECSx](https://hexdocs.pm/ecsx)

  - Components
    - are restricted to scalar values
    - are stored seperately in different tables
