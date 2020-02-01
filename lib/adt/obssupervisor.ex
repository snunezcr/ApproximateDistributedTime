defmodule Adt.ObserverSupervisor do
  use DynamicSupervisor
  import Adt.ClockConfig
  import Adt.ObserverConfig

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_observer(obs_id, clk_config, obs_config) do
    spec = {Adt.Clock, [obs_id, clk_config, obs_config]}
    DynamicSupervisor.start_child(@me, spec)
  end

  def all_observers() do
    DynamicSupervisor.which_children(@me)
  end
end
