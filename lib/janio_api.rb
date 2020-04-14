require "janio_api/version"
require "active_resource"
require "dotenv/load"
require_relative "zeitwerk_loader"

# if || (defined?(Rails) && Rails::VERSION::MAJOR >= 6)
# end

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
