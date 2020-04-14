module JanioAPI
##
# See http://apidocs.janio.asia/faq for parameters information
  class Order < Base
    self.prefix = "/api/order/orders/"
    self.element_name = ""

    validate :check_api_token

    def check_api_token
      errors.add(:base, "Please set the api_token in the initializer file") if JanioAPI.config.api_token.blank?
    end

    class Collection < ActiveResource::Collection
      attr_accessor :count, :next, :previous

      def initialize(parsed = {})
        @count = parsed["count"]
        @next = parsed["next"]
        @previous = parsed["previous"]
        @elements = parsed["results"]
      end
    end

    self.collection_parser = Collection

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
        options[:params] = {} unless options[:params]
        options[:params][:secret_key] = JanioAPI.config.api_token
        options[:params][:with_items] = true unless options[:params][:with_items]

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

      # Track one or more tracking nos
      #
      # Check http://apidocs.janio.asia/track for more information
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

    # Tracks the current order
    #
    # Check http://apidocs.janio.asia/track for more information
    def track
      body = {
        get_related_updates: true,
        flatten_data: true,
        tracking_nos: [@attributes["tracking_no"]]
      }
      response = connection.post(self.class.tracking_path, body.to_json, self.class.headers)
      self.class.format.decode(response.body)[0]
    end

    def save(blocking: true)
      run_callbacks :save do
        new? ? create(blocking: blocking) : update(blocking: blocking)
      end
    end

    def create(blocking: true)
      reformat_before_save(blocking)
      super()
    rescue => e
      reset_attributes_format
      raise e
    end

    def update(blocking: true)
      reformat_before_save(blocking)
      super()
    rescue => e
      reset_attributes_format
      raise e
    end

    # Reformat the attributes before POST to server
    def reformat_before_save(blocking)
      attributes = @attributes.dup
      @attributes.clear
      @attributes["secret_key"] = JanioAPI.config.api_token
      # set blocking until label generated
      @attributes["blocking"] = blocking
      # reformat attributes
      @attributes["orders"] = [attributes]
    end

    def reset_attributes_format
      attributes = @attributes.dup
      @attributes.clear
      load(attributes.delete("orders")[0])
    end

    def load_attributes_from_response(response)
      # reset the attributes structure before assign attributes that came back from server
      reset_attributes_format

      # save the response attributes
      if response_code_allows_body?(response.code.to_i) &&
          (response["Content-Length"].nil? || response["Content-Length"] != "0") &&
          !response.body.nil? && response.body.strip.size > 0

        attributes = self.class.format.decode(response.body)
        attributes.merge!(attributes["orders"][0]).delete("orders")
        load(attributes, false, true)
        @persisted = true
      end
    end
  end
end
