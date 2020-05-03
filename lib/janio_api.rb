require "janio_api/version"
require "active_resource"

module JanioAPI
  require "phonelib"
  require "countries"

  require "janio_api/services_list"

  require "janio_api/configuration"

  require "janio_api/redirect_fetcher"

  require "janio_api/connection"

  require "janio_api/resources/base"
  require "janio_api/resources/item"
  require "janio_api/resources/order"
end
