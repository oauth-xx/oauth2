require 'httpauth'

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
        raise NotImplementedError, "The authorization endpoint is not used in this strategy"
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(params={}, opts={})
        request_body = opts.delete('auth_scheme') == 'request_body'
        params.merge!('grant_type' => 'client_credentials')
        params.merge!(request_body ? client_params : {:headers => {'Authorization' => HTTPAuth::Basic.pack_authorization(client_params['client_id'], client_params['client_secret'])}})
        @client.get_token(params, opts.merge('refresh_token' => nil))
      end
    end
  end
end
