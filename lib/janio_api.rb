require "janio_api/version"
require "active_resource"
require "dotenv/load"
require_relative "zeitwerk_loader"

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
