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
        extract_legacy_params!(params)
        # ^ This can go away whenever we decide to no longer preserve previous gem behavior of restricting keys

        url_params = params[:url_params]
        claims = params[:claims]
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

      def extract_legacy_params!(params)
        # In previous versions of this gem, `:scope` defaulted to being in the POST request body outside the claimset.
        # Additionally, :iss, :aud, :prn, and :exp were the only four keys and always present in the claimset
        #
        # This method is intended to preserve that behavior, and can be removed when no longer needed
        #
        # If you are seeing a deprecation warning in your app: the `params` argument to Assertion is now split into:
        # params = { :url_params => {}, :claims => {} }

        params[:url_params] ||= {}
        params[:claims] ||= {}
        legacy_url_params = {}
        legacy_claims = {}

        if params.has_key?(:scope)
          puts "DEPRECATION WARNING: params[:scope] is defaulted to a header value -- this behavior may go away!"
          legacy_url_params[:scope] = params.delete(:scope)
        end

        [:iss, :aud, :prn, :exp].each do |legacy_key|
          if params.has_key?(legacy_key)
            puts "DEPRECATION WARNING: params[#{legacy_key}] is a legacy default claim -- this behavior may go away!"
            legacy_claims[legacy_key] = params.delete(legacy_key)
          end
        end

        params[:url_params].merge!(legacy_url_params)
        params[:claims].merge!(legacy_claims)
      end
    end
  end
end
