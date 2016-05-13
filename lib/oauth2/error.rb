require 'kconv'

module OAuth2
  class Error < StandardError
    attr_reader :response, :code, :description

    # standard error values include:
    # :invalid_request, :invalid_client, :invalid_token, :invalid_grant, :unsupported_grant_type, :invalid_scope
    def initialize(response)
      response.error = self
      @response = response

      message = []

      if response.parsed.is_a?(Hash)
        @code = response.parsed['error']
        @description = response.parsed['error_description']
        message << "#{@code}: #{@description}"
      end

      if message[0] && message[0].respond_to?(:encoding)
        script_encoding = message[0].encoding
        response_body_encoding = response.body.encoding
        response_body = response.body.kconv(script_encoding, response_body_encoding)
      else
        response_body = response.body
      end

      message << response_body

      super(message.join("\n"))
    end
  end
end
