module JanioAPI
  class Configuration
    attr_accessor :api_host, :api_token
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.config=(config)
    @config = config
  end

  def self.configure
    yield config
    # set the site once user configure
    JanioAPI::Base.site = JanioAPI.config.api_host
  end
end
