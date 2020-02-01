defmodule Adt.Observer do
  # Assumption: the observer and the clock are entities with different frames of reference. Hence,
  # their perception of time differs. However, we do not use the observer's frame of reference, since
  # it is in general directly inaccessible to a complex entity. This explains our use of MicroTimer here.
  use GenServer, restart: :transient

  require Logger
  import Adt.ClockSupervisor

  alias Adt.ClockConfig
  alias Adt.ClockState
  alias Adt.ObserverConfig
  alias Adt.ObserverState
  alias Adt.Clock

  alias Adt.ClockSupervisor

  alias Adt.Policies.Aggregation
  alias Adt.Policies.Update

  @me __MODULE__
  @registry_clk :clocks_registry
  @registry_obs :observers_registry

  # API

  def start_link([obs_config, clk_config, obs_id]) do
    GenServer.start_link @me, [obs_id, clk_config, obs_config], name: via_tuple(obs_id)
  end

  def start(obs_id) do
    # Start the clock
    Clock.start obs_id
    # Let the system equilibrate
    GenServer.cast via_tuple(obs_id), :equilibrate
    # Start sampling
    GenServer.cast via_tuple(obs_id), :sample
  end

  def stop(obs_id) do
    GenServer.cast via_tuple(obs_id), :stop
  end

  def query(obs_id) do
    GenServer.cast via_tuple(obs_id), :query
  end

  def peer(obs_id) do
    GenServer.cast via_tuple(obs_id), :peer
  end

  # server

  def init([obs_id, clk_config, obs_config]) do
    # Create a clock with the same id as the observer
    ClockSupervisor.create_clock(obs_id, clk_config)

    # Create an observer with the appropriate configuration
    %ObserverConfig{res: _, ping: _, prep: _, pcovt: _,
      frefn: frn, prefn: prn, k: k_init, equ: _, strat: _, aggr: _,
      bmax: _, btime: _, tobs: ts} = obs_config

    frs = first_fixed_peers(obs_id, frn, ts)
    prs = first_provisional_peers(obs_id, prn, frs, ts)

    {:ok, {obs_id, obs_config, %ObserverState{
                                  samples: 0,
                                  epoch: 0,
                                  now: 0,
                                  frefs: frs,
                                  prefs: prs,
                                  last_chkp: 0,
                                  k_now: k_init,
                                  b_now: 0}}}
  end

  def handle_cast(:equilibrate, {obs_id, config, state}) do
    %ObserverConfig{res: rs, ping: _, prep: _, pcovt: _,
      frefn: _, prefn: _, k: _, equ: eq, strat: _, aggr: _,
      bmax: _, btime: _, tobs: _} = config

      %ClockState{now: t, tmr: _} = Clock.watch obs_id
      Logger.info("Equilibrating at: #{t}", observer: obs_id)

      if t > rs*eq do
        MicroTimer.usleep(rs)
        schedule_equilibrate(obs_id)
      else
        {:noreply, {obs_id, config, state}}
      end
  end

  def handle_cast(:sample, {obs_id, config, state}) do
    %ObserverConfig{res: rs, ping: _, prep: _, pcovt: _,
      frefn: _, prefn: _, k: _, equ: _, strat: _, aggr: _,
      bmax: _, btime: _, tobs: _} = config

    MicroTimer.usleep(rs)

    %ClockState{now: t, tmr: _} = Clock.watch obs_id
    # Update handling logic goes here

    Logger.info("Clock time: #{t}", observer: obs_id)
    schedule_sample(obs_id)
    {:noreply, {obs_id, config, state}}
  end

  def handle_cast(:stop, {obs_id, config, state}) do
    {:stop, "Observer operation finalized", {obs_id, config, state}}
  end

  # private functions

  ## Registry handler
  defp via_tuple(name),
    do: {:via, Registry, {@registry_obs, name}}

  ## Peer management functions
  defp first_fixed_peers(obs_id, frefn, tobs) do
    Enum.take_random((for n <- 1..tobs, do: n) -- [obs_id], frefn)
  end

  defp first_provisional_peers(obs_id, prefn, frefs, tobs) do
    Enum.take_random((for n <- 1..tobs, do: n) -- [obs_id|frefs], prefn)
  end

  ## Equilibration related functions
  defp schedule_equilibrate(obs_id) do
    GenServer.cast via_tuple(obs_id), :equilibrate
  end

  ## Sampling related functions
  defp sample(obs_id, config) do
    %ClockConfig{withtimer: _, res: rs, nav_tick: nt, nav_watch: _, nav_set: _} = config
    ndev = round(abs(:rand.normal(nt, :math.sqrt(nt)))) + rs
    MicroTimer.usleep(ndev)
    #GenServer.cast via_tuple(clk_id), {:increment, ndev}
  end

  defp schedule_sample(obs_id) do
    GenServer.cast via_tuple(obs_id), :sample
  end

  ## Oracle related functions
  defp timer_cov(samples, req) do
    Statistex.standard_deviation(samples)/req
  end
end
