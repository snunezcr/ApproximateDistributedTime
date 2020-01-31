defmodule Adt.Clock do
  use GenServer, restart: :transient
  import Adt.ClockState
  alias Adt.ClockState

  @me __MODULE__

  # API
  def start_link({wt, rs, nt, nw, ns}) do
    GenServer.start_link(@me, {wt, rs, nt, nw, ns}, name: @me)
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

  def timer(state, req) do
    %ClockState{withtimer: wt, now: t, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns} = state

    if wt do
      if req < 10*nt do
        # If the noise average is less than 10 times higher, we do not introduce noise
        MicroTimer.usleep(req)
        %ClockState{withtimer: wt, now: t, tmr: req, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}
      else
        wait = req + round(abs(:rand.normal(nt, :math.sqrt(nt))))
        MicroTimer.usleep(wait)
        %ClockState{withtimer: wt, now: t, tmr: wait, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}
      end
    else
      %ClockState{withtimer: wt, now: t, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}
    end
  end

  # server
  def init({wt, rs, nt, nw, ns}) do
    IO.puts "Clock initialized"
    {:ok, %ClockState{withtimer: wt, now: 0, tmr: 0, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}}
  end

  defp increment(state) do
    %ClockState{withtimer: _, now: _, tmr: _, res: rs, nav_tick: nt, nav_watch: _, nav_set: _} = state

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

  def handle_cast(:tick, state) do
    increment(state)
    schedule_tick()
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, "Clock operation finalized", state}
  end

  def handle_cast({:increment, inc}, state) do
    %ClockState{withtimer: wt, now: t, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns} = state
    {:noreply, %ClockState{withtimer: wt, now: t + inc, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}}
  end

  def handle_call(:watch, _from, state) do
    %ClockState{withtimer: wt, now: t, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns} = state
    # Introduce a small amount of variance from watching the clock
    wdev = round(abs(:rand.normal(nt, :math.sqrt(nw))))
    new_state = %ClockState{withtimer: wt, now: t + wdev, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}
    {:reply, new_state, new_state}
  end

  def handle_call({:set, new_now}, _from, state) do
    %ClockState{withtimer: wt, now: _, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns} = state
    # Introduce a slightly larger amount of variance from setting the clock
    sdev = round(abs(:rand.normal(nt, :math.sqrt(nw))))
    new_state = %ClockState{withtimer: wt, now: new_now + sdev, tmr: tm, res: rs, nav_tick: nt, nav_watch: nw, nav_set: ns}
    {:reply, new_state, new_state}
  end

  def handle_call({:timer, millis}, _from, state) do
    new_state = timer(state, millis)
    {:reply, new_state, new_state}
  end
end
