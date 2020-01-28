import Config

config :adt, Adt.History.Repo,
  adapter: Sqlite.Ecto2,
  database: "history.sqlite"

config :adt, ecto_repos: [Adt.History.Repo]
