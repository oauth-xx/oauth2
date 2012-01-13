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
        params = {'grant_type' => 'client_credentials'}.merge(client_params).merge(params)
        @client.get_token(params, opts.merge('refresh_token' => nil))
      end
    end
  end
end
