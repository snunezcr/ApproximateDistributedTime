defmodule Adt.ObserverState do
  defstruct id: 0,
            now: 0,
            frefs: [],
            prefs: [],
            last_chkp: 0,
            k_now: 0,
            b_now: 0
end
