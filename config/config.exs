import Config

# Send application logs to stderr so stdout is used only for MCP messages.
# This keeps logs out of protocol responses without changing return values.
config :logger, :default_handler, config: [type: :standard_error]
