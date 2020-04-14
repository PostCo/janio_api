require "janio_api/version"
require "active_resource"
require "dotenv/load"
# require_relative "zeitwerk_loader"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "janio_api" => "JanioAPI"
)
loader.collapse("./lib/janio_api/resources")
loader.enable_reloading
loader.tag = "janio_api_gem"
# loader.log!
loader.setup
$__janio_api_loader__ = loader
if ENV["JANIO_API_GEM_ENV"] == "development"
  def reload!
    $__janio_api_loader__.reload
  end
end

module JanioAPI
  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config)
    end

    class Configuration
      attr_accessor :api_host, :api_token
    end
  end
end
