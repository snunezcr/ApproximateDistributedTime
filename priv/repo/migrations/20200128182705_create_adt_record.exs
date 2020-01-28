defmodule Adt.History.Repo.Migrations.CreateAdtRecord do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :pid,   :string
      add :policy, :integer
      add :period, :float
      add :timestamp, :float
      add :timediff, :float
      add :step, :integer
    end
  end
end
