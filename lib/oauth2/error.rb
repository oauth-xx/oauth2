module OAuth2
  class Error < StandardError
    attr_reader :response, :code, :description

    # standard error values include:
    # :invalid_request, :invalid_client, :invalid_token, :invalid_grant, :unsupported_grant_type, :invalid_scope
    def initialize(response)
      response.error = self
      @response = response
      if response.parsed.is_a?(Hash)
        @code = response.parsed['error']
        @description = response.parsed['error_description']
      end
    end

  end
end
