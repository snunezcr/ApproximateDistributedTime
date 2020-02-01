import Config

config :adt, Adt.History.Repo,
  adapter: Sqlite.Ecto2,
  database: "history.sqlite"

config :adt, ecto_repos: [Adt.History.Repo]

config :logger,
  backends: [{LoggerFileBackend, :debug_log}, {LoggerFileBackend, :info_log}]

config :logger, :debug_log,
  path: 'debugLog.log',
  level: :debug

config :logger, :info_log,
  path: 'infoLog.log',
  level: :info
