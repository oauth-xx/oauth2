require 'jwt'

module OAuth2
  module Strategy
    # The Client Assertion Strategy
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-10#section-4.1.3
    #
    # Sample usage:
    #   client = OAuth2::Client.new(client_id, client_secret,
    #                               :site => 'http://localhost:8080')
    #
    #   params = {:hmac_secret => "some secret",
    #             # or :private_key => "private key string",
    #             :iss => "http://localhost:3001",
    #             :prn => "me@here.com",
    #             :exp => Time.now.utc.to_i + 3600}
    #
    #   access = client.assertion.get_token(params)
    #   access.token                 # actual access_token string
    #   access.get("/api/stuff")     # making api calls with access token in header
    #
    class Assertion < Base
      # Not used for this strategy
      #
      # @raise [NotImplementedError]
      def authorize_url
        raise(NotImplementedError, 'The authorization endpoint is not used in this strategy')
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params assertion params
      # pass either :hmac_secret or :private_key, but not both.
      #
      #   params :hmac_secret, secret string.
      #   params :private_key, private key string.
      #
      # for possible claim keys, see https://tools.ietf.org/html/rfc7519#section-4.1
      #
      #   params :iss, issuer
      #   params :aud, audience, optional
      #   params :prn, principal, current user
      #     ^ DEPRECATED: prn is now 'sub' https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-06#appendix-F
      #   params :exp, expired at, in seconds, like Time.now.utc.to_i + 3600
      #
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        hash = build_request(params)
        @client.get_token(hash, opts.merge('refresh_token' => nil))
      end

      def build_request(params)
        url_params = params[:url_params] || {}
        claims = params[:claims] || {}
        encoding_options = choose_algorithm!(params)

        {
          :grant_type => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          :assertion => build_assertion(claims, encoding_options),
        }.merge(url_params)
      end

    private

      def choose_algorithm!(params)
        # Right now there is only the choice of HS256 or RS256, but this could be expanded

        private_key = params.delete(:private_key)
        hmac_secret = params.delete(:hmac_secret)

        if hmac_secret
          {:algorithm => 'HS256', :key => hmac_secret}
        elsif private_key
          {:algorithm => 'RS256', :key => private_key}
        else
          raise ArgumentError.new(:message => 'Either hmac_secret or private_key is required for JWT encoding!')
        end
      end

      def build_assertion(claims, encoding_options)
        JWT.encode(claims, encoding_options[:key], encoding_options[:algorithm])
      end
    end
  end
end
