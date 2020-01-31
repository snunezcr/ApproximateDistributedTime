defmodule Adt.Clock do
  use GenServer, restart: :transient
  import Adt.ClockState
  import Adt.ClockConfig
  alias Adt.ClockState
  alias Adt.ClockConfig

  @me __MODULE__

  # API
  def start_link(%ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}) do
    GenServer.start_link(@me, %ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns})
  end

  def start() do
    GenServer.cast(@me, :tick)
  end

  def watch() do
    GenServer.call(@me, :watch)
  end

  def set(new_now) do
    GenServer.call(@me, {:watch, new_now})
  end

  def timer(millis) do
    GenServer.call @me, {:timer, millis}
  end

  def stop() do
    GenServer.cast @me, :stop
  end

  defp set_timer(config, state, req) do
      %ClockConfig{withtimer: wt, res: _, nav_tick: nt, nav_watch: _, nav_set: _} = config
      %ClockState{now: t, tmr: tm} = state

    if wt do
      if req < 10*nt do
        # If the noise average is less than 10 times higher, we do not introduce noise
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
  def init(%ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}) do
    IO.puts "Clock initialized"
    {:ok, { %ClockConfig{withtimer: wt, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}, %ClockState{now: 0, tmr: 0}}}
  end

  defp increment(config) do
    %ClockConfig{withtimer: _, res: rs, nav_tick: nt, nav_watch: _, nav_set: _} = config

    # Generate a random deviate with the square root of the noise average as standard deviation
    ndev = round(abs(:rand.normal(nt, :math.sqrt(nt)))) + rs

    # Wait the required amount of microseconds
    MicroTimer.usleep(ndev)
    IO.puts "Tick length: #{ndev}\n"

    GenServer.cast @me, {:increment, ndev}
  end

  defp schedule_tick() do
    IO.puts "ticking"
    GenServer.cast @me, :tick
  end

  def handle_cast(:tick, {config, state}) do
    increment(config)
    schedule_tick()
    {:noreply, {config, state}}
  end

  def handle_cast(:stop, {config, state}) do
    {:stop, "Clock operation finalized", {config, state}}
  end

  def handle_cast({:increment, inc}, {config, state}) do
    %ClockState{now: t, tmr: tm} = state
    {:noreply, {config, %ClockState{now: t + inc, tmr: tm}}}
  end

  def handle_call(:watch, _from, {config, state}) do
    %ClockConfig{withtimer: _, res: _, nav_tick: _, nav_watch: nw, nav_set: _} = config
    %ClockState{now: t, tmr: tm} = state
    # Introduce a small amount of variance from watching the clock
    wdev = round(abs(:rand.normal(nw, :math.sqrt(nw))))
    new_state = %ClockState{now: t + wdev, tmr: tm}
    {:reply, new_state, new_state}
  end

  def handle_call({:set, new_now}, _from, {config, state}) do
    %ClockConfig{withtimer: _, res: _, nav_tick: _, nav_watch: _, nav_set: ns} = config
    %ClockState{now: _, tmr: tm} = state
    # Introduce a slightly larger amount of variance from setting the clock
    sdev = round(abs(:rand.normal(ns, :math.sqrt(ns))))
    new_state = %ClockState{now: new_now + sdev, tmr: tm}
    {:reply, new_state, {config, new_state}}
  end

  def handle_call({:timer, millis}, _from, {config, state}) do
    new_state = set_timer(config, state, millis)
    {:reply, new_state, {config, new_state}}
  end
end
