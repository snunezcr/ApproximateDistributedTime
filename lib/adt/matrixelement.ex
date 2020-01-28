defmodule Adt.MatrixElement do
  use Ecto.Schema
  alias Adt.Record

  schema "matrixelements" do
    belongs_to :record, Record
    field :pid_me, :string
    field :pid_ref, :string
    field :step, :integer
  end
end
