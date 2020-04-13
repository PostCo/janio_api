require "janio_api/version"
require "active_resource"
require_relative "zeitwerk_loader"

module JanioAPI
  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config)
    end
  end

  class Error < StandardError; end
  # Your code goes here...
end

JanioAPI.configure do |config|
  config.api_host = ENV["API_HOST"]
  config.api_token = ENV["API_TOKEN"]
end
