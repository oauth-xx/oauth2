require 'multi_json'

module OAuth2
  module Strategy
    class AuthCode < Base
      def authorize_params(params={})
        super(params).merge('response_type' => 'code')
      end

      def authorize_url(params={})
        @client.authorize_url(authorize_params.merge(params))
      end

      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_token(code, params={})
        params = { 'grant_type' => 'authorization_code', 'code' => code }.merge(client_params).merge(params)
        OAuth2::AccessToken.from_token_params(@client, params)
      end
    end
  end
end
