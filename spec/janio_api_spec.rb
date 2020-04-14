RSpec.describe JanioAPI do
  let(:order) do
    JanioAPI::Order.new({
      service_id: 1,
      tracking_no: "TRACKINGNUMBERHTH333ASDA1",
      shipper_order_id: nil,
      order_length: 12,
      order_width: 12,
      order_height: 12,
      order_weight: 12,
      payment_type: "cod",
      cod_amount_to_collect: 40.5,
      consignee_name: "Susan",
      consignee_number: "+6291234567891",
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
      pickup_date: nil,
      pickup_notes: nil,
      items: [
        {
          item_desc: "Blue Male T-Shirt",
          item_quantity: 2,
          item_product_id: "PROD123",
          item_sku: "ITEMSKU123",
          item_category: "Fashion Apparel",
          item_price_value: 23.5,
          item_price_currency: "IDR"
        }
      ]
    })
  end
  it "has a version number" do
    expect(JanioAPI::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
