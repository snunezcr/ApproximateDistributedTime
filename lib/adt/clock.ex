defmodule Adt.Clock do
  use GenServer, restart: :transient
  import Adt.ClockState
  import Adt.ClockConfig
  alias Adt.ClockState
  alias Adt.ClockConfig

  @me __MODULE__
  @registry_clk :clocks_registry

  # API
  def start_link([config, clk_id]) do
    GenServer.start_link @me, [config, clk_id], name: via_tuple(clk_id)
  end

  def start(clk_id) do
    GenServer.cast(via_tuple(clk_id), :tick)
  end

  def watch(clk_id) do
    GenServer.call(via_tuple(clk_id), :watch)
  end

  def set(clk_id, new_now) do
    GenServer.call(via_tuple(clk_id), {:set, new_now})
  end

  def timer(clk_id, millis) do
    GenServer.call via_tuple(clk_id), {:timer, millis}
  end

  def stop(clk_id) do
    GenServer.cast via_tuple(clk_id), :stop
  end

  defp set_timer(config, state, req) do
      %ClockConfig{withtimer: wt, res: _, nav_tick: nt, nav_watch: _, nav_set: _} = config
      %ClockState{now: t, tmr: tm} = state

    if wt do
      if req < 10*nt do
        MicroTimer.usleep(req)
        %ClockState{now: t, tmr: req}
      else
        wait = req + round(abs(:rand.normal(nt, :math.sqrt(nt))))
        MicroTimer.usleep(wait)
        %ClockState{now: t, tmr: wait}
      end
    else
      %ClockState{now: t, tmr: tm}
    end
  end

  # server
  def init([config, clk_id]) do
    IO.puts "Clock initialized"
    {:ok, {clk_id, config, %ClockState{now: 0, tmr: 0}}}
  end

  defp increment(clk_id, config) do
    %ClockConfig{withtimer: _, res: rs, nav_tick: nt, nav_watch: _, nav_set: _} = config
    ndev = round(abs(:rand.normal(nt, :math.sqrt(nt)))) + rs
    MicroTimer.usleep(ndev)
    GenServer.cast via_tuple(clk_id), {:increment, ndev}
  end

  defp schedule_tick(clk_id) do
    GenServer.cast via_tuple(clk_id), :tick
  end

  def handle_cast(:tick, {clk_id, config, state}) do
    increment(clk_id, config)
    schedule_tick(clk_id)
    {:noreply, {clk_id, config, state}}
  end

  def handle_cast(:stop, {clk_id, config, state}) do
    {:stop, "Clock operation finalized", {clk_id, config, state}}
  end

  def handle_cast({:increment, inc}, {clk_id, config, state}) do
    %ClockState{now: t, tmr: tm} = state
    {:noreply, {clk_id, config, %ClockState{now: t + inc, tmr: tm}}}
  end

  def handle_call(:watch, _from, {clk_id, config, state}) do
    %ClockConfig{withtimer: _, res: _, nav_tick: _, nav_watch: nw, nav_set: _} = config
    %ClockState{now: t, tmr: tm} = state
    # Introduce a small amount of variance from watching the clock
    wdev = round(abs(:rand.normal(nw, :math.sqrt(nw))))
    new_state = %ClockState{now: t + wdev, tmr: tm}
    {:reply, new_state, {clk_id, config, new_state}}
  end

  def handle_call({:set, new_now}, _from, {clock_id, config, state}) do
    %ClockConfig{withtimer: _, res: _, nav_tick: _, nav_watch: _, nav_set: ns} = config
    %ClockState{now: _, tmr: tm} = state
    # Introduce a slightly larger amount of variance from setting the clock
    sdev = round(abs(:rand.normal(ns, :math.sqrt(ns))))
    new_state = %ClockState{now: new_now + sdev, tmr: tm}
    {:reply, new_state, {clock_id, config, new_state}}
  end

  def handle_call({:timer, millis}, _from, {clock_id, config, state}) do
    new_state = set_timer(config, state, millis)
    {:reply, new_state, {clock_id, config, new_state}}
  end

  defp via_tuple(name),
    do: {:via, Registry, {@registry_clk, name} }
end
