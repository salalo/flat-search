# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :flat_search,
  ecto_repos: [FlatSearch.Repo]

# Configures the endpoint
config :flat_search, FlatSearchWeb.Endpoint,
  # url: [host: "localhost"],
  url: [host: "long-meek-chitall.gigalixirapp.com"],
  secret_key_base: "obKqEiH/GP7H+VX8NdcSJ4rVqR+bvxE0PkaW88cmZs+kWpo1Z0QDzJG9Af/hj/HY",
  render_errors: [view: FlatSearchWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FlatSearch.PubSub,
  live_view: [signing_salt: "5mQ4Wuge"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :flat_search, FlatSearch.Scheduler,
  jobs: [
    {"*/20 * * * *", {FlatSearch.OlxScraper, :run, []}}
  ]

config :flat_search, FlatSearchWeb.Gettext,
  default_locale: "pl",
  locales: ~w(pl en)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
