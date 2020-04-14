module JanioAPI
  class Base < ::ActiveResource::Base
    self.include_root_in_json = false
    self.include_format_in_path = false
    self.connection_class = JanioAPI::Connection

    if JanioAPI.config&.api_host
      self.site = JanioAPI.config.api_host
    else
      raise ArgumentError, "Please set the api_host in the initializer file"
    end
  end
end
