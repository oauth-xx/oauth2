module OAuth2
  class Error < StandardError
    attr_reader :response, :code, :description

    # standard error values include:
    # :invalid_request, :invalid_client, :invalid_token, :invalid_grant, :unsupported_grant_type, :invalid_scope
    def initialize(response)
      response.error = self
      @response = response

      message = []

      set_response_code(response)

      if @code
        message << "#{@code}: #{@description}"
      end

      message << response.body

      super(message.join("\n"))
    end

    ## Subclass should override this if repsonse use different keys for error code/description
    ## E.g. https://github.com/acenqiu/weibo2/blob/master/lib/weibo2/error.rb
    def set_response_code(response)
      if response.parsed.is_a?(Hash)
        @code = response.parsed['error']
        @description = response.parsed['error_description']
      end
    end


  end
end
