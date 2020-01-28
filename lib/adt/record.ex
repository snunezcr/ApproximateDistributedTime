defmodule Adt.Record do
  use Ecto.Schema

  schema "records" do
    field :pid, :string
    field :policy, :integer
    field :period, :float
    field :timestamp, :float
    field :step, :integer
  end
end
