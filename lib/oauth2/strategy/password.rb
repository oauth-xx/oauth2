require 'multi_json'

module OAuth2
  module Strategy
    class Password < Base
      def authorize_url
        raise NotImplementedError, "The authorization endpoint is not used in this strategy"
      end
      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_access_token(username, password, options={})
        response = @client.request(:post, @client.access_token_url, access_token_params(username, password, options))

        access   = response.parsed.delete('access_token')
        refresh  = response.parsed.delete('refresh_token')
        expires_in = response.parsed.delete('expires_in')
        OAuth2::AccessToken.new(@client, access, refresh, expires_in, response.parsed)
      end

      def access_token_params(username, password, options={}) #:nodoc:
        super(options).merge({
          'grant_type'  => 'password',
          'username'    => username,
          'password'    => password
        })
      end
    end
  end
end
