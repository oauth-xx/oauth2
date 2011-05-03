require 'multi_json'

module OAuth2
  module Strategy
    class WebServer < Base
      def authorize_params(options={}) #:nodoc:
        super(options).merge('response_type' => 'code')
      end

      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_access_token(code, options={})
        response = get_token(access_token_params(code, options))
        parse_token_response(response)
      end

      def refresh_access_token(refresh_token, options={})
        response = get_token(refresh_token_params(refresh_token, options))
        parse_token_response(response, refresh_token)
      end
      
      def get_token(params)
        args = @client.options[:access_token_method] == :get ? { :params => params } : { :body => params }
        @client.request(@client.options[:access_token_method], @client.access_token_url, args)
      end

      def access_token_params(code, options={}) #:nodoc:
        super(options).merge({
          'grant_type' => 'authorization_code',
          'code' => code,
        })
      end

      def refresh_token_params(refresh_token, options={}) #:nodoc:
        super(options).merge({
          'grant_type' => 'refresh_token',
          'refresh_token' => refresh_token,
        })
      end

      def parse_token_response(response, refresh_token=nil)
        access = response.parsed.delete('access_token')
        refresh = response.parsed.delete('refresh_token') || refresh_token
        expires_in = response.parsed.delete('expires_in') || response.parsed.delete('expires')
        OAuth2::AccessToken.new(@client, access, refresh, expires_in, response.parsed)
      end
    end
  end
end
