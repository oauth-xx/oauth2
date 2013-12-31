require 'base64'

module OAuth2
  module Strategy
    # The Client Credentials Strategy
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.4
    class ClientCredentials < Base
      # Not used for this strategy
      #
      # @raise [NotImplementedError]
      def authorize_url
        fail(NotImplementedError, 'The authorization endpoint is not used in this strategy')
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        request_body = opts.delete('auth_scheme') == 'request_body'
        params.merge!('grant_type' => 'client_credentials')
        params.merge!(request_body ? client_params : {:headers => {'Authorization' => authorization(client_params['client_id'], client_params['client_secret'])}})
        @client.get_token(params, opts.merge('refresh_token' => nil))
      end

      # Returns the Authorization header value for Basic Authentication
      #
      # @param [String] The client ID
      # @param [String] the client secret
      def authorization(client_id, client_secret)
        'Basic ' + Base64.encode64(client_id + ':' + client_secret).gsub("\n", '')
      end
    end
  end
end
