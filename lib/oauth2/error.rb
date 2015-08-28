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

      #https://github.com/intridea/oauth2/issues/155
      message << response.body.force_encoding("UTF-8")

      super(message.join("\n"))
    end
  end
end
