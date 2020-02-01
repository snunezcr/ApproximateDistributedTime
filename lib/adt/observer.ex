defmodule Adt.Observer do
  use GenServer, restart: :transient

  import Adt.ClockConfig
  import Adt.ObserverState
  import Adt.ObserverConfig
  alias Adt.ClockConfig
  alias Adt.ObserverConfig
  alias Adt.ObserverState

  @me __MODULE__
  @registry_clk :clocks_registry
  @registry_obs :observers_registry


end
