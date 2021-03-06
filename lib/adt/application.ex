defmodule Adt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @registry_clk :clocks_registry
  @registry_obs :observers_registry

  def start(_type, _args) do
    children = [
      { Registry, [keys: :unique, name: @registry_clk]},
      { Registry, [keys: :unique, name: @registry_obs]},
      { Adt.ClockSupervisor, []},
      { Adt.ObserverSupervisor, []},
      Adt.History.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Adt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
