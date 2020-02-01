defmodule Adt.History.Repo.Migrations.CreateAdtRecord do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :pid, :string
      add :aggr_policy, :string
      add :updt_policy, :string
      add :period, :float
      add :timestamp, :float
      add :timediff, :float
      add :epoch, :integer
    end
  end
end
