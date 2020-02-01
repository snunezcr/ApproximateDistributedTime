defmodule Adt.ClockSupervisor do
  use DynamicSupervisor

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_clock(clk_config, id) do
    spec = {Adt.Clock, [clk_config, id]}
    DynamicSupervisor.start_child(@me, spec)
  end

  def all_clocks() do
    DynamicSupervisor.which_children(@me)
  end
end
