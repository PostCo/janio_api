module JanioAPI
  class Base < ::ActiveResource::Base
    self.include_root_in_json = false
    self.include_format_in_path = false
    self.connection_class = JanioAPI::Connection
    self.site = JanioAPI.config&.api_host
  end
end
