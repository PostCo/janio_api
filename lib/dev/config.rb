require "dotenv/load"

def set_config
  JanioAPI.configure do |config|
    config.api_host = ENV["API_HOST"]
    config.api_token = ENV["API_TOKEN"]
    # or
    # api_tokens take higher precedence than api_token
    # config.api_tokens = {
    #   MY: ENV["MY_API_TOKEN"],
    #   SG: ENV["SG_API_TOKEN"]
    # }
  end
end
