module OAuth2
  module Strategy
    # The SAML Assertion Strategy
    #
    # @see https://tools.ietf.org/html/draft-ietf-oauth-saml2-bearer-23
    #
    # Sample usage:
    #   client = OAuth2::Client.new(client_id, client_secret,
    #                               :token_url => 'http://api.example.com/token')
    #
    #   params = {:grant_type  => 'urn:ietf:params:oauth:grant-type:saml2-bearer',
    #             :assertion => '<saml:Assertion>stuff</saml:Assertion>'
    #             :scope => 'scope1,scope2'}
    #   access = client.saml_assertion.get_token(params, 'auth_scheme' => 'request_body')
    #   access.token                 # actual access_token string
    #   access.get("/api/stuff")     # making api calls with access token in header
    #
    class SamlAssertion < Base
      # Not used for this strategy
      #
      # @raise [NotImplementedError]
      def authorize_url
        fail NotImplementedError, 'The authorization endpoint is not used in this strategy'
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        hash = params.merge(client_params)
        @client.get_token(hash, opts.merge('refresh_token' => nil))
      end
    end
  end
end