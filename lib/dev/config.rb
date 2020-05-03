require "dotenv/load"

def set_config
  JanioAPI.configure do |config|
    config.api_host = ENV["API_HOST"]
    config.api_token = ENV["API_TOKEN"]
  end
end
