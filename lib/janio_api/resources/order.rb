module JanioAPI
  ##
  # See http://apidocs.janio.asia/faq for parameters information
  class Order < Base
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

    SUPPORTED_PICKUP_COUNTRIES = ["Singapore", "China", "Hong Kong", "Indonesia", "Malaysia", "Philippines", "Thailand"].freeze
    SUPPORTED_CONSIGNEE_COUNTRIES = ["Indonesia", "Singapore", "Thailand", "Malaysia", "Philippines", "China", "Hong Kong", "Taiwan", "Brunei", "South Korea", "Japan", "Vietnam"].freeze

    POSTAL_EXCLUDED_COUNTRIES = ["Hong Kong", "Vietnam", "Brunei"].freeze
    VALID_PAYMENT_TYPES = ["cod", "prepaid"].freeze

    SERVICE_ID_MAP = [
      {id: 1, from: "Singapore", to: "Indonesia"},
      {id: 6, from: "China", to: "Indonesia"},
      {id: 5, from: "China", to: "Singapore"},
      {id: 7, from: "China", to: "Thailand"},
      {id: 11, from: "Hong Kong", to: "Indonesia"},
      {id: 37, from: "Hong Kong", to: "Malaysia"},
      {id: 33, from: "Hong Kong", to: "Philippines"},
      {id: 13, from: "Hong Kong", to: "Singapore"},
      {id: 12, from: "Hong Kong", to: "Thailand"},
      {id: 41, from: "Indonesia", to: "China"},
      {id: 41, from: "Indonesia", to: "Hong Kong"},
      {id: 41, from: "Indonesia", to: "Taiwan"},
      {id: 41, from: "Indonesia", to: "Brunei"},
      {id: 41, from: "Indonesia", to: "Philippines"},
      {id: 41, from: "Indonesia", to: "Malaysia"},
      {id: 3, from: "Indonesia", to: "Indonesia"},
      {id: 47, from: "Indonesia", to: "Philippines"},
      {id: 54, from: "Indonesia", to: "Philippines"},
      {id: 20, from: "Indonesia", to: "Singapore"},
      {id: 48, from: "Indonesia", to: "Singapore"},
      {id: 22, from: "Indonesia", to: "South Korea"},
      {id: 22, from: "Indonesia", to: "Japan"},
      {id: 22, from: "Indonesia", to: "Vietnam"},
      {id: 4, from: "Malaysia", to: "Indonesia"},
      {id: 40, from: "Malaysia", to: "Malaysia"},
      {id: 36, from: "Philippines", to: "Philippines"},
      {id: 2, from: "Singapore", to: "China"},
      {id: 2, from: "Singapore", to: "Taiwan"},
      {id: 2, from: "Singapore", to: "South Korea"},
      {id: 2, from: "Singapore", to: "Brunei"},
      {id: 2, from: "Singapore", to: "Vietnam"},
      {id: 2, from: "Singapore", to: "Hong Kong"},
      {id: 2, from: "Singapore", to: "Japan"},
      {id: 26, from: "Singapore", to: "Malaysia"},
      {id: 10, from: "Singapore", to: "Singapore"},
      {id: 17, from: "Singapore", to: "Thailand"},
      {id: 34, from: "Thailand", to: "Indonesia"},
      {id: 35, from: "Thailand", to: "Singapore"}
    ].freeze

    self.prefix = "/api/order/orders/"
    self.element_name = ""

    has_many :items, class_name: "JanioAPI::Item"

    validates :service_id, :order_length, :order_width, :order_height, :order_weight, :cod_amount_to_collect, :consignee_name, :consignee_number, :consignee_country,
      :consignee_address, :consignee_state, :consignee_email, :pickup_contact_name, :pickup_contact_number, :pickup_country, :pickup_address,
      :pickup_state, :pickup_date, presence: true

    validates :pickup_country, inclusion: {in: SUPPORTED_PICKUP_COUNTRIES, message: "%{value} is not a supported pickup country, supported countries are #{SUPPORTED_PICKUP_COUNTRIES.join(", ")}"}
    validates :consignee_country, inclusion: {in: SUPPORTED_CONSIGNEE_COUNTRIES, message: "%{value} is not a supported consignee country, supported countries are #{SUPPORTED_CONSIGNEE_COUNTRIES.join(", ")}"}
    validates :pickup_postal, :consignee_postal, presence: true, unless: -> { POSTAL_EXCLUDED_COUNTRIES.include?(consignee_country) }
    validates :pickup_postal, presence: true, unless: -> { POSTAL_EXCLUDED_COUNTRIES.include?(pickup_country) }
    validates :payment_type, inclusion: {in: VALID_PAYMENT_TYPES, message: "%{value} is not a valid payment type, valid payment types are #{VALID_PAYMENT_TYPES.join(", ")}"}
    validates :cod_amount_to_collect, presence: true, if: -> { payment_type == "cod" }
    validates :items, length: {minimum: 1, message: "are required. Please add at least one."}
    validate :items_validation
    validate :route_supported?

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

    def initialize(attributes = {}, persisted = false)
      default_attrs = {
        service_id: 1,
        tracking_no: nil,
        shipper_order_id: nil,
        order_length: 12,
        order_width: 12,
        order_height: 12,
        order_weight: 1,
        payment_type: nil,
        cod_amount_to_collect: 0,
        consignee_name: nil,
        consignee_number: nil,
        consignee_country: nil,
        consignee_address: nil,
        consignee_postal: nil,
        consignee_state: nil,
        consignee_city: nil,
        consignee_province: nil,
        consignee_email: nil,
        pickup_contact_name: nil,
        pickup_contact_number: nil,
        pickup_country: nil,
        pickup_address: nil,
        pickup_postal: nil,
        pickup_state: nil,
        pickup_city: nil,
        pickup_province: nil,
        pickup_date: nil,
        pickup_notes: nil,
        items: nil
      }
      attributes = default_attrs.merge(attributes)
      super
      set_service_id
    end

    def get_service_id
      SERVICE_ID_MAP.find { |route| route[:from] == pickup_country && route[:to] == consignee_country }&.dig(:id)
    end

    def set_service_id
      @attributes[:service_id] = get_service_id
    end

    # Tracks the current order
    #
    # Check http://apidocs.janio.asia/track for more information
    def track
      body = {
        get_related_updates: true,
        flatten_data: true,
        tracking_nos: [@attributes[:tracking_no]]
      }
      response = connection.post(self.class.tracking_path, body.to_json, self.class.headers)
      self.class.format.decode(response.body)[0]
    end

    def save(blocking: true)
      run_callbacks :save do
        new? ? create(blocking: blocking) : update(blocking: blocking)
      end
    end

    private

    def route_supported?
      unless set_service_id
        errors.add(:route, "not supported, if new route not available in service_id_map, please contact gem author.")
      end
    end

    def items_validation
      items&.each_with_index do |item, index|
        item.errors.full_messages.each { |msg| errors.add("item_#{index}".to_sym, msg) } unless item.valid?
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
      @attributes[:secret_key] = JanioAPI.config.api_token
      # set blocking until label generated
      @attributes[:blocking] = blocking
      # reformat attributes
      @attributes[:orders] = [attributes]
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
