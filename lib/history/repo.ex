defmodule Adt.History.Repo do
  use Ecto.Repo, otp_app: :adt, adapter: Sqlite.Ecto2
end
