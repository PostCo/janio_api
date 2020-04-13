module JanioAPI
  class Base < ::ActiveResource::Base
    self.include_root_in_json = false
    self.include_format_in_path = false
    # self.connection_class = PickuppAPI::Connection
  end
end
