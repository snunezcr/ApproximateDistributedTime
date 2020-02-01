defmodule Adt.ObserverConfig do
  alias Adt.Policies.Aggregation
  alias Adt.Policies.Update

  defstruct res: 0,
            ping: 50000,
            prep: 5,
            pcovt: 0.05,
            frefn: 1,
            prefn: 1,
            k: 1000000,
            equ: 10,
            strat: Update.Fixed,
            aggr: Aggregation.Avg,
            bmax: 3,
            btime: 25000,
            tobs: 1
end
