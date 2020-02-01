defmodule Adt.Observer do
  use GenServer, restart: :transient

  import Adt.ClockSupervisor

  alias Adt.ClockConfig
  alias Adt.ObserverConfig
  alias Adt.ObserverState

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
    GenServer.cast(via_tuple(obs_id), :tick)
  end

  def stop(obs_id) do
    GenServer.cast via_tuple(obs_id), :stop
  end

  def query(obs_id) do
    Adt.Clock.watch obs_id
  end

  def peer(obs_id) do

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
                                  epoch: 0,
                                  now: 0,
                                  frefs: frs,
                                  prefs: prs,
                                  last_chkp: 0,
                                  k_now: k_init,
                                  b_now: 0}}}
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

  ## Oracle related functions
  defp timer_cov(samples, req) do
    Statistex.standard_deviation(samples)/req
  end
end
