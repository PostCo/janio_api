module JanioAPI
  class Base < ::ActiveResource::Base
    self.include_root_in_json = false
    self.include_format_in_path = false
    self.connection_class = JanioAPI::Connection

    class << self
      def headers
        if _headers_defined?
          _headers
        elsif superclass != Object && superclass.headers
          superclass.headers
        else
          _headers ||= {}
        end
      end
    end
  end
end
