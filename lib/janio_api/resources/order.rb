module JanioAPI
  class Order < Base
    self.prefix = "/api/order/"

    class << self
      def tracking_path
        "/api/tracker/query-by-tracking-nos/"
      end

      # override find to customize url, and only allow find_every
      # use to find the parcel info, include the label pdf url
      # check http://apidocs.janio.asia/view for more information
      # params accept tracking numbers as well: ```tracking_no=[tracking_no1],[tracking_no2],[tracking_no3]```
      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}
        options[:from] = "/api/order/order" unless options[:from]
        options[:params][:secret_key] = JanioAPI.config.api_token

        case scope
        when :all
          find_every(options)
        when :first
          collection = find_every(options)
          collection&.first
        when :last
          collection = find_every(options)
          collection&.last
        end
      end

      # check http://apidocs.janio.asia/track for more information
      def track(tracking_nos)
        raise ArgumentError, "tracking_nos not an array" unless tracking_nos.is_a?(Array)

        body = {
          get_related_updates: true,
          flatten_data: true,
          tracking_nos: tracking_nos
        }
        response = connection.post(tracking_path, body.to_json, headers)

        self.format.decode(response.body)
      end
    end

    # check http://apidocs.janio.asia/track for more information
    def track
      body = {
        get_related_updates: true,
        flatten_data: true,
        tracking_nos: [@attributes["tracking_no"]]
      }
      response = connection.post(self.class.tracking_path, body.to_json, self.class.headers)
      self.class.format.decode(response.body)[0]
    end

    def create(blocking: true)
      reformat_before_save(blocking)
      super
    end

    def update(blocking: true)
      reformat_before_save(blocking)
      super
    end

    def reformat_before_save(blocking)
      @attributes["secret_key"] = JanioAPI.config.api_token
      # set blocking until label generated
      @attributes["blocking"] = blocking
      # reformat attributes
      @attributes["orders"] = [@attributes.except("secret_key", "blocking")]
    end

    def load_attributes_from_response(response)
      # reset the attributes structure before assign attributes that came back from server
      load(@attributes.delete("orders"))
      super(response)
    end
  end
end
