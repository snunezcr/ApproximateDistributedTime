defmodule Adt.ClockSupervisor do
  use DynamicSupervisor

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_clock({wt, rs, nt, nw, ns}) do
    spec = { Adt.Clock, {wt, rs, nt, nw, ns}}
    {:ok, _pid} = DynamicSupervisor.start_child(@me, spec)
  end

  def all_clocks() do
    DynamicSupervisor.which_children(@me)
  end
end
