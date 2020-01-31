defmodule Adt.ObserverState do
  defstruct id: "",
            now: 0,
            frefs: [],
            prefs: [],
            clock: nil
end
