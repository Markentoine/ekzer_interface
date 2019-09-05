# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ekzer_interface, EkzerInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vEaw80Cq75C2o0QEaRJwgZo/h8r0qvKtlibPeWzh3acSFO6sltXWxX6rleMQT3EN",
  render_errors: [view: EkzerInterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EkzerInterface.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Drab
config :drab, EkzerInterfaceWeb.Endpoint,
  otp_app: :ekzer_interface

# Configures default Drab file extension
config :phoenix, :template_engines,
  drab: Drab.Live.Engine

# Configures Drab for webpack
config :drab, EkzerInterfaceWeb.Endpoint,
  js_socket_constructor: "window.__socket"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
