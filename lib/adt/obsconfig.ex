defmodule Adt.ObserverConfig do
  defstruct res: 0,
            o2cres: 1,
            frefn: 1,
            prefn: 1,
            strat: :non_adaptive,
            bmax: 3,
            btime: 25000
end
