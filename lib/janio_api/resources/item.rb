module JanioAPI
  class Item < Base
    VALID_ITEM_CATEGORIES = ["Fashion Accessories", "Fashion Footwear", "Fashion Apparels (Men)", "Fashion Apparels (Women)",
                             "Fashion Apparels (Babies, Toddlers and Children)", "Fashion Apparel", "Electronics",
                             "Electronics (Non-Telecommunications)", "Electronics (Telecommunications)", "Lifestyle Products",
                             "Lifestyle (Health Related)", "Lifestyle (Beauty Related)", "Lifestyle (Home & Living)",
                             "Lifestyle (Hobbies & Collection)", "Lifestyle (Pantry & Packaged Food & Beverages)", "Others", "Printed Matters"].freeze
    validates :item_desc, :item_quantity, :item_price_value, :item_price_currency, presence: true
    validates :item_category, inclusion: {in: VALID_ITEM_CATEGORIES, message: "%{value} is not a valid item category, valid item categories are #{VALID_ITEM_CATEGORIES.join(", ")}"}

    class << self
      def find(*args)
        raise "JanioAPI::Item cannot be fetched directly, plesase use JanioAPI::Order to fetch the items under the order."
      end

      def create
        raise "JanioAPI::Item cannot be created directly, "\
        "please include it in an JanioAPI::Order to create it under a new JanioAPI::Order."
      end
    end

    def initialize(attributes = {}, persisted = false)
      default_attrs = {
        item_desc: nil, item_quantity: nil, item_price_value: nil, item_price_currency: nil, item_category: nil
      }
      attributes = default_attrs.merge(attributes)
      super
    end

    def create
      self.class.create
    end

    def update
      raise "JanioAPI::Item cannot be updated, only creation is supported and "\
      "please include it in an JanioAPI::Order to create it under a new JanioAPI::Order."
    end
  end
end
