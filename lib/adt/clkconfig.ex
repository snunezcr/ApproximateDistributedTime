defmodule Adt.ClockConfig do
  defstruct withtimer: false,
            res: 0,
            nav_tick: 0,
            nav_watch: 0,
            nav_set: 0
end
