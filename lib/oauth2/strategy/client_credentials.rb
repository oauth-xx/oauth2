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
        raise(NotImplementedError, 'The authorization endpoint is not used in this strategy')
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        params = params.merge('grant_type' => 'client_credentials')

        request_body = opts.delete('auth_scheme') == 'request_body'
        if request_body
          params.merge!(client_params)
        else
          authorization_header = {'Authorization' => authorization(client_params['client_id'], client_params['client_secret'])}
          params[:headers] = (params[:headers] || {}).merge(authorization_header)
        end

        @client.get_token(params, opts.merge('refresh_token' => nil))
      end
    end
  end
end
