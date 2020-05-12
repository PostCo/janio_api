require "setup_helper"

RSpec.describe JanioAPI do
  it "has a version number" do
    expect(JanioAPI::VERSION).not_to be nil
  end

  describe "JanioAPI::Order" do
    let(:attributes) do
      {
        service_id: nil,
        tracking_no: "TRACKINGNUMBERHTH333ASDA1",
        shipper_order_id: nil,
        order_length: 12,
        order_width: 12,
        order_height: 12,
        order_weight: 12,
        payment_type: "cod",
        cod_amount_to_collect: 40.5,
        consignee_name: "Susan",
        consignee_number: "+622127899808",
        consignee_country: "Indonesia",
        consignee_address: "Pos 5 security komp perumahan PT INALUM tanjung gading., Jln berangin.",
        consignee_postal: "12420",
        consignee_state: "Daerah Khusus Ibukota Jakarta",
        consignee_city: "Jakarta Selatan",
        consignee_province: "Cilandak",
        consignee_email: "susan123@email.com",
        pickup_contact_name: "Jackson",
        pickup_contact_number: "+6591234567",
        pickup_country: "Singapore",
        pickup_address: "Jurong West Ave 1",
        pickup_postal: "640534",
        pickup_state: "Singapore State",
        pickup_city: nil,
        pickup_province: nil,
        pickup_date: ((Time.now + 1.week)).to_s,
        pickup_notes: nil,
        items: [
          {item_desc: "Blue Male T-Shirt",
           item_quantity: 2,
           item_product_id: "PROD123",
           item_sku: "ITEMSKU123",
           item_category: "Fashion Apparel",
           item_price_value: 23.5,
           item_price_currency: "IDR"}
        ]
      }
    end
    let(:order) do
      JanioAPI::Order.new(attributes)
    end

    it "auto set service id based on pickup and consignee country" do
      expect(order.service_id).to eq(1)
    end

    describe "validation" do
      context "success" do
        it { expect(order.valid?).to be true }
      end

      describe "presences" do
        attrs = [:service_id, :order_length, :order_width, :order_height, :order_weight, :consignee_name, :consignee_country,
                 :consignee_address, :consignee_state, :consignee_email, :pickup_contact_name, :pickup_country, :pickup_address,
                 :pickup_state, :pickup_date]

        attrs.each do |attr|
          before { order.send("#{attr}=", nil) }
          it do
            order.valid?
            expect(order.errors.messages.keys).to include(attr.to_s.to_sym)
          end
        end
      end

      shared_examples "country inclusion" do |country_type|
        before do
          order.send("#{country_type}=", country)
          order.valid?
        end

        context "with invalid country name" do
          let(:country) { "Non existent country" }
          it { expect(order.errors.messages.keys).to include(country_type) }
        end

        context "with valid country name" do
          let(:country) { "Malaysia" }
          it { expect(order.errors.messages.keys).not_to include(country_type) }
        end
      end

      describe "pickup_country inclusion" do
        include_examples "country inclusion", :pickup_country
      end
      describe "consignee_country inclusion" do
        include_examples "country inclusion", :consignee_country
      end

      shared_examples "postal presence" do |postal_type, country_type|
        before do
          order.send("#{postal_type}=", postal)
          order.send("#{country_type}=", country.to_s) if defined?(country)
          order.valid?
        end

        context "with empty postal" do
          let(:postal) { "" }
          it { expect(order.errors.messages.keys).to include(postal_type) }
        end

        context "with non-empty postal" do
          let(:postal) { "12435" }
          it { expect(order.errors.messages.keys).not_to include(postal_type) }
        end

        context "with empty postal for Vietnam" do
          let(:postal) { "" }
          let(:country) { "Vietnam" }
          it { expect(order.errors.messages.keys).not_to include(postal_type) }
        end
      end

      describe "pickup_postal presence" do
        include_examples "postal presence", :pickup_postal, :pickup_country
      end

      describe "consignee_postal presence" do
        include_examples "postal presence", :consignee_postal, :consignee_country
      end

      describe "payment_type inclusion" do
        context "valid" do
          it do
            order.payment_type = "cod"
            order.valid?
            expect(order.errors.messages.keys).not_to include(:payment_type)
          end
          it do
            order.payment_type = "prepaid"
            order.valid?
            expect(order.errors.messages.keys).not_to include(:payment_type)
          end
        end

        context "invalid" do
          it do
            order.payment_type = "invalid payment type"
            order.valid?
            expect(order.errors.messages.keys).to include(:payment_type)
          end
        end
      end

      describe "cod_amount_to_collect inclusion" do
        context "valid" do
          it do
            order.payment_type = "prepaid"
            order.cod_amount_to_collect = nil
            order.valid?
            expect(order.errors.messages.keys).not_to include(:cod_amount_to_collect)
          end
          it do
            order.payment_type = "cod"
            order.cod_amount_to_collect = 12.34
            order.valid?
            expect(order.errors.messages.keys).not_to include(:cod_amount_to_collect)
          end
        end

        context "invalid" do
          it do
            order.payment_type = "cod"
            order.cod_amount_to_collect = nil
            order.valid?
            expect(order.errors.messages.keys).to include(:cod_amount_to_collect)
          end
        end
      end

      describe "items count" do
        context "0 items" do
          it do
            order.items = nil
            order.valid?
            expect(order.errors.messages.keys).to include(:items)
          end
        end
      end

      shared_examples "contact_number" do |phone_attr, country_attr|
        context "cannot be nil" do
          it do
            order.send("#{phone_attr}=", nil)
            order.valid?
            expect(order.errors.messages.keys).to include(phone_attr)
          end
        end

        context "must match address country" do
          it do
            order = JanioAPI::Order.new
            order.send("#{country_attr}=", "Malaysia")
            order.send("#{phone_attr}=", "+65-955-5368-8")
            order.valid?

            expect(order.errors.messages.keys).to include(phone_attr)
          end
        end
      end

      describe "pickup_contact_number" do
        include_examples "contact_number", :pickup_contact_number, :pickup_country
      end

      describe "consignee_number" do
        include_examples "contact_number", :consignee_number, :consignee__country
      end

      describe "route_supported?" do
        context "unsupported route" do
          before do
            order.pickup_country = "Vietnam"
            order.consignee_country = "South Africa"
            order.valid?
          end
          it { expect(order.errors.messages.keys).to include(:route) }
        end
      end
    end

    describe "private #reformat_before_save" do
      context "by default" do
        before { order.send(:reformat_before_save, true) }
        it do
          expect(order.orders.first.keys.map(&:to_sym)).to eq(attributes.keys)
        end
        it "secret key eq JanioAPI.config.api_token" do
          expect(order.secret_key).to eq JanioAPI.config.api_token
        end
        it { expect(order.blocking).to be true }
      end

      context "with api_tokens set" do
        before do
          JanioAPI.config.api_tokens = {
            MY: "janio malaysia token",
            SG: "janio singapore token"
          }
          order.send(:reformat_before_save, true)
        end

        it "retrieve token based on pickup_country(Singapore) from api_tokens, instead of api_token" do
          expect(order.secret_key) == "janio singapore token"
        end

        it "retrieve token based on pickup_country(Malaysia)" do
          order.pickup_country = "Malaysia"
          expect(order.secret_key) == "janio malaysia token"
        end
      end
    end
  end
end
