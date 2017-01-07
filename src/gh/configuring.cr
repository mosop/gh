module Gh
  extend GlobalConfig::Store

  global_config :access_token, env: {:GITHUB_ACCESS_TOKEN}
  global_config_context :auth, :access_token
end
