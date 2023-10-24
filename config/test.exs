import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :text_server, TextServer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ajax_multicommentary_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :text_server, TextServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "j0pXE8VvRetrmM5CZLu20cBg52vtcHTb5m0D2GWVw9D0Q/KvtDEUHNUBgNZCbyEP",
  server: false

config :text_server, Oban, testing: :inline

# In test we don't send emails.
config :text_server, TextServer.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
