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

    SUPPORTED_PICKUP_COUNTRIES = SERVICES.map { |s| s[:pickup_country] }.uniq.freeze
    SUPPORTED_CONSIGNEE_COUNTRIES = SERVICES.map { |s| s[:consignee_country] }.uniq.freeze
    PICKUP_DATE_ACCEPTED_COUNTRIES = ["Singapore"]

    POSTAL_EXCLUDED_COUNTRIES = ["Hong Kong", "Vietnam", "Brunei"].freeze
    VALID_PAYMENT_TYPES = ["cod", "prepaid"].freeze

    DEFAULT_ATTRS = {
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
    self.prefix = "/api/order/orders/"
    self.element_name = ""

    has_many :items, class_name: "JanioAPI::Item"

    validates :service_id, :order_length, :order_width, :order_height, :order_weight,
      :consignee_name, :consignee_country, :consignee_address, :consignee_state, :consignee_email,
      :pickup_contact_name, :pickup_country, :pickup_address, :pickup_state, presence: true

    validates :pickup_date, presence: true, if: -> { PICKUP_DATE_ACCEPTED_COUNTRIES.include?(pickup_country) }
    validates :pickup_date, absence: true, if: -> { !PICKUP_DATE_ACCEPTED_COUNTRIES.include?(pickup_country) }
    validates :pickup_country, inclusion: {
      in: SUPPORTED_PICKUP_COUNTRIES,
      message: "%{value} is not a supported pickup country, supported countries are #{SUPPORTED_PICKUP_COUNTRIES.join(", ")}"
    }
    validates :consignee_country, inclusion: {
      in: SUPPORTED_CONSIGNEE_COUNTRIES,
      message: "%{value} is not a supported consignee country, supported countries are #{SUPPORTED_CONSIGNEE_COUNTRIES.join(", ")}"
    }
    validates :payment_type, inclusion: {
      in: VALID_PAYMENT_TYPES,
      message: "%{value} is not a valid payment type, valid payment types are #{VALID_PAYMENT_TYPES.join(", ")}"
    }
    validates :cod_amount_to_collect, presence: true, if: -> { payment_type == "cod" }
    validates :items, length: {minimum: 1, message: "are required. Please add at least one."}
    validate :pickup_postal_valid?, unless: -> { POSTAL_EXCLUDED_COUNTRIES.include?(pickup_country) }
    validate :consignee_postal_valid?, unless: -> { POSTAL_EXCLUDED_COUNTRIES.include?(consignee_country) }
    validate :pickup_contact_number_country_matched?
    validate :consignee_number_country_matched?
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
        options[:params][:with_items] = true unless options[:params][:with_items]
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

      # Track one or more tracking nos
      #
      # Check http://apidocs.janio.asia/track for more information
      def track(tracking_nos)
        raise ArgumentError, "tracking_nos must be an array" unless tracking_nos.is_a?(Array)

        body = {
          get_related_updates: true,
          flatten_data: false,
          tracking_nos: tracking_nos
        }

        retries = 0
        begin
          retries += 1
          response = connection.post(tracking_path, body.to_json, headers)
        rescue ActiveResource::ConnectionError => e
          retry unless retries <= 5
          raise e
        end

        self.format.decode(response.body)
      end
    end

    def initialize(attributes = {}, persisted = false)
      if attributes[:pickup_date].is_a?(ActiveSupport::TimeWithZone)
        attributes[:pickup_date] = attributes[:pickup_date].strftime("%Y-%-m-%-d")
      end
      attributes = DEFAULT_ATTRS.merge(attributes)
      super
      set_service_id
    end

    def pickup_date=(date)
      @attributes[:pickup_date] = if date.is_a?(ActiveSupport::TimeWithZone) || date.is_a?(Time)
        date.strftime("%Y-%-m-%-d")
      else
        date
      end
    end

    def get_service_id(service_category = "pickup")
      # only check with services offering pickup by default
      SERVICES.find do |s|
        s[:pickup_country] == pickup_country &&
          s[:consignee_country] == consignee_country &&
          s[:service_category] == service_category
      end&.dig(:id)
    end

    def set_service_id(service_category = "pickup")
      @attributes[:service_id] = get_service_id(service_category)
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

    def pickup_country_code
      ISO3166::Country.find_country_by_name(pickup_country)&.alpha2
    end

    def consignee_country_code
      ISO3166::Country.find_country_by_name(consignee_country)&.alpha2
    end

    def pickup_postal_valid?
      if pickup_country_code
        regex = Regexp.new(POSTAL_CODE_REGEX[pickup_country_code.to_sym])
        errors.add(:pickup_postal, "is invalid, must match #{regex.inspect}") unless regex.match(pickup_postal)
      end
    end

    def consignee_postal_valid?
      if consignee_country_code && POSTAL_CODE_REGEX[consignee_country_code.to_sym]
        regex = Regexp.new(POSTAL_CODE_REGEX[consignee_country_code.to_sym])
        errors.add(:consignee_postal, "is invalid, must match #{regex.inspect}") unless regex.match(consignee_postal)
      end
    end

    def pickup_contact_number_country_matched?
      if Phonelib.invalid_for_country?(pickup_contact_number, pickup_country_code)
        errors.add(
          :pickup_contact_number,
          "is invalid, please make sure the phone is valid and phone's country code matches the pickup address's country"
        )
      end
    end

    def consignee_number_country_matched?
      if Phonelib.invalid_for_country?(consignee_number, consignee_country_code)
        errors.add(
          :consignee_number,
          "is invalid, please make sure the phone is valid and phone's country code matches the consignee address's country"
        )
      end
    end

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
      @attributes[:secret_key] = retrieve_api_token(attributes[:pickup_country])
      # set blocking until label generated
      @attributes[:blocking] = blocking
      # reformat attributes
      @attributes[:orders] = [attributes]
    end

    def retrieve_api_token(country)
      if JanioAPI.config.api_tokens
        country_code_sym = ISO3166::Country.find_country_by_name(country)&.alpha2&.to_sym
        JanioAPI.config.api_tokens[country_code_sym]
      elsif JanioAPI.config.api_token
        JanioAPI.config.api_token
      else
        raise ArgumentError, "JanioAPI api_token/api_tokens is missing, please set it in the config."
      end
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
