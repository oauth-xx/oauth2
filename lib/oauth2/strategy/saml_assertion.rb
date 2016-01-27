module OAuth2
  module Strategy
    class SamlAssertion < Base
      def authorize_url
        fail NotImplementedError, 'The authorization endpoint is not used in this strategy'
      end

      def get_token(params = {}, opts = {})
        hash = params.merge(client_params)
        @client.get_token(hash, opts.merge('refresh_token' => nil))
      end
    end
  end
end