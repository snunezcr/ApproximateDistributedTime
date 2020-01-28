defmodule Adt.Record do
  use Ecto.Schema

  schema "records" do
    field :pid_me, :string
    field :pid_ref, :string
    field :step, :integer
  end
end
