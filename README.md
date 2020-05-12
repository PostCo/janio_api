# JanioAPI

[![Gem Version](https://badge.fury.io/rb/janio_api.svg)](https://badge.fury.io/rb/janio_api)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'janio_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install janio_api

## Usage

### Setup

1. Create a file under the `initializers` folder.
2. Set the `api_host` and `api_token` as following sample:

   ```ruby
   JanioAPI.configure do |config|
     config.api_host = ENV["API_HOST"]

     config.api_token = ENV["API_TOKEN"]
     # or
     # api_tokens will take over api_token if set in config
     config.api_tokens = {
       MY: ENV["MALAYSIA_JANIO_API_TOKEN"],
       SG: ENV["SINGAPORE_JANIO_API_TOKEN"],
     }
   end
   ```

### Creation

1. Here's an example:

   ```ruby
   attributes={
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
   }

   order = JanioAPI::Order.new(attributes)
   order.save
   ```

2. Make sure you use `#valid?` or `#save_with_validation` to catch errors before POST to the server.

   ```ruby
     unless order.valid?
       # handle invalid order
     end

     #or

     unless order.save_with_validation
       # handle invalid order
     end
   ```

### Tracking

1. You are recommended to use the webhook provided by Janio to capture the latest parcel's status.
2. You can also track the parcel using the `#track` or `.track([one or more tracking number])`. Examples:

   ```ruby
     JanioAPI::Order.track(["tracking_no1", "tracking_no2"]) # one or more tracking number

     # or

     JanioAPI::Order.new({tracking_no: "tracking_no1"}).track
   ```

### Update

- Update is not supported yet

### Deletion

- Deletion is not supported yet

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODO list

- [ ] Add test for Order creation.
- [ ] Figure out order update.
- [ ] Figure out order deletion.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PostCo/janio_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/PostCo/janio_api/blob/master/CODE_OF_CONDUCT.md).

### Gem Building Guide

Please read this [guide](https://bundler.io/guides/creating_gem.html), it is very helpful for beginner gem builder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JanioAPI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/PostCo/janio_api/blob/master/CODE_OF_CONDUCT.md).
