defmodule Adt.ClockState do
  # All time constants are in microseconds

  defstruct withtimer: false,
            now: 0.0,
            tmr: 0.0,
            res: 0.0,
            nav_tick: 0.0,
            nav_watch: 0.0,
            nav_set: 0.0
end
