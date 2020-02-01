defmodule Adt.ObserverSupervisor do
  use DynamicSupervisor
  import Adt.ClockConfig
  import Adt.ObserverConfig
  alias Adt.ClockConfig
  alias Adt.ObserverConfig

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def observer_name(id) do
    "observer_#{id}"
  end

  def all_observers() do
    DynamicSupervisor.which_children(@me)
  end
end
