# JanioAPI

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/janio_api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

1. Create a file under the `initializers` folder.
2. Set the `api_host` and `api_token` as following sample:
   ```ruby
   JanioAPI.configure do |config|
     config.api_host = ENV["API_HOST"]
     config.api_token = ENV["API_TOKEN"]
   end
   ```
3. Then you can start creating Janio orders! Here's an example:

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PostCo/janio_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/janio_api/blob/master/CODE_OF_CONDUCT.md).

### Gem Building Guide

Please read this [guide](https://bundler.io/guides/creating_gem.html), it is very helpful for beginner gem builder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JanioAPI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/janio_api/blob/master/CODE_OF_CONDUCT.md).
