defmodule Adt.ClockSupervisor do
  use DynamicSupervisor
  import Adt.ClockConfig
  alias Adt.ClockConfig

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(@me, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def clock_name(id) do
    "clock_#{id}"
  end

  def create_clock(%ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}, id) do
    spec = {Adt.Clock, %ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}, clock_name(id)}
    {:ok, _pid} = DynamicSupervisor.start_child(@me, spec)
  end

  def all_clocks() do
    DynamicSupervisor.which_children(@me)
  end
end
