module JanioAPI
  class RedirectFetcher
    def self.get(src)
      uri = URI.parse(src)

      proxy = OpenStruct.new

      http_proxy = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password)

      redirect_limit = 6
      response = nil

      loop do
        raise ArgumentError, "HTTP redirect too deep" if redirect_limit == 0
        redirect_limit -= 1

        http = http_proxy.new(uri.host, uri.port)

        request = Net::HTTP::Get.new(uri.request_uri, {})
        if uri.instance_of? URI::HTTPS
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = http.request(request)

        if response.code == "200"
          break
        elsif response.code == "304"
          break
        elsif response.code == "301" || response.code == "302" || response.code == "303" || response.code == "307"

          newuri = URI.parse(response.header["location"])
          if newuri.relative?
            newuri = uri + response.header["location"]
          end
          uri = newuri
        else
          break
        end
      end

      response
    end
  end
end
