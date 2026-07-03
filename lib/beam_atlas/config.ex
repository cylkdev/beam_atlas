defmodule BeamAtlas.Config do
  @moduledoc false

  @spec logger_default_handler_config_type() :: atom() | nil
  def logger_default_handler_config_type do
    Application.get_env(:logger, :default_handler)[:config][:type]
  end
end
