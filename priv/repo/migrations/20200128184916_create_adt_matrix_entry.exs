defmodule Adt.History.Repo.Migrations.CreateAdtMatrixEntry do
  use Ecto.Migration

  def change do
    create table(:matrixelements) do
      add :pid_me, :string
      add :pid_ref, :string
      add :step, :integer
      add :record_id, references(:records)
    end
  end
end
