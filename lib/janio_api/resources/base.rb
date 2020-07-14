module JanioAPI
  class Base < ::ActiveResource::Base
    self.include_root_in_json = false
    self.include_format_in_path = false
    self.connection_class = JanioAPI::Connection

    def initialize(attributes = {}, persisted = false)
      # check if config host and api token is set
      unless JanioAPI.config.api_tokens || JanioAPI.config.api_token
        raise ArgumentError, "JanioAPI api_token/api_tokens is missing, please set it in the config."
      end

      unless JanioAPI.config.api_host
        raise ArgumentError, "JanioAPI api_host is missing, please set it in the config."
      end

      super
    end
  end
end
