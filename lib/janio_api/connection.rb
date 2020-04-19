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
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end

    private

    def handle_response(response)
      case response.code.to_i
      when 200...400
        response
      when 400
        raise(BadRequest.new(response))
      when 401
        raise(UnauthorizedAccess.new(response))
      when 403
        raise(ForbiddenAccess.new(response))
      when 404
        raise(ResourceNotFound.new(response))
      when 405
        raise(MethodNotAllowed.new(response))
      when 409
        raise(ResourceConflict.new(response))
      when 410
        raise(ResourceGone.new(response))
      when 422
        raise(ResourceInvalid.new(response))
      when 401...500
        raise(ClientError.new(response))
      when 500...600
        raise(ServerError.new(response))
      else
        raise(ConnectionError.new(response, "Unknown response code: #{response.code}"))
      end
    end
  end
end
