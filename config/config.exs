# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :spelling,
  ecto_repos: [Spelling.Repo]

# Configures the endpoint
config :spelling, SpellingWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [
    signing_salt: "SECRET_SALT"
  ],
  secret_key_base: "9fqQWl58orS7KPvrmqaa+x12NfwwTKWRSsJsCoalgD6aq7Ee7W4OiAwo1k0lJyr8",
  render_errors: [view: SpellingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Spelling.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
