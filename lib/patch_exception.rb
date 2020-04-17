module ActiveResource
  class ConnectionError < StandardError # :nodoc:
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message = message
    end

    def to_s
      message = "Failed.".dup
      message << "  Response code = #{response.code}." if response.respond_to?(:code)
      message << "  Response message = #{response.message}." if response.respond_to?(:message)
      message << "  Response body = #{response.body}." if response.respond_to?(:body)
      message
    end
  end
end
