defmodule Adt.Policies do
  use EnumType

  defenum Aggregation do
    value Avg, "obs_average"
    value Max, "obs_max"
    default Avg
  end

  defenum Update do
    value Fixed, "k_fixed"
    value Adaptive, "k_adaptive"
    value Oracle, "k_oracle"
  end

end
