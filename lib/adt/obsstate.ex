defmodule Adt.ObserverState do
  defstruct samples: 0,
            epoch: 0,
            now: 0,
            frefs: [],
            prefs: [],
            last_chkp: 0,
            k_now: 0,
            b_now: 0
end
