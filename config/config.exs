import Config

if config_env() in [:dev] do
  import_config "#{config_env()}.exs"
end
