module JanioAPI
  class Connection < ActiveResource::Connection
    def request(method, path, *arguments)
      result = ActiveSupport::Notifications.instrument("request.active_resource") { |payload|
        payload[:method] = method
        payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"

        payload[:result] = if method == :get
          RedirectFetcher.get("#{site}#{path}")
        else
          http.send(method, path, *arguments)
        end
      }
      handle_response(result)
    rescue Timeout::Error => e
      raise ActiveResource::TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise ActiveResource::SSLError.new(e.message)
    end
  end
end
