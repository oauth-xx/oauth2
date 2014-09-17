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
        fail(NotImplementedError, 'The authorization endpoint is not used in this strategy')
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params assertion params
      # pass either :hmac_secret or :private_key, but not both.
      #
      #   params :hmac_secret, secret string.
      #   params :private_key, private key string.
      #
      #   params :iss, issuer
      #   params :aud, audience, optional
      #   params :sub, principal, current user
      #   params :exp, expired at, in seconds, like Time.now.utc.to_i + 3600
      #
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        hash = build_request(params)
        @client.get_token(hash, opts.merge('refresh_token' => nil))
      end

      # Build request payload with grant_type set to assertion
      def build_request(params)
        assertion = build_assertion(params)
        {:grant_type     => 'assertion',
         :assertion_type => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
         :assertion      => assertion,
         :scope          => params[:scope],
        }.merge(client_params)
      end

      # Build a JSON Web Token (JWT). A JWT is composed of three parts: a header, a claim set, and a signature.
      # The header and claim set are JSON objects. These JSON objects are serialized to UTF-8 bytes, then encoded
      # using the Base64url encoding. This encoding provides resilience against encoding changes due to repeated
      # encoding operations. The header, claim set, and signature are concatenated together with a period (.) character.
      #
      # @param [Hash] params claim set to sign with given secret (or key). It may contain following values plus
      #                      any other value that will be part of final JWT
      #
      # @option params [String] :iss claim that contains a unique identifier for the entity that issued the JWT
      # @option params [String] :sub claim identifying the principal that is the subject of the JWT
      # @option params [String] :aud claim containing a value that identifies the authorization
      #                              server as an intended audience.
      # @option params [Integer] :exp claim that limits the time window during which the JWT can be used
      # @option params [Integer] :nbf claim that identifies the time before which the token MUST NOT be
      #                               accepted for processing
      # @option params [Integer] :iat claim that identifies the time at which the JWT was issued
      # @option params [Integer] :jti claim that provides a unique identifier for the token
      #
      # @return [String] the signed JWT as a base64 encoded string
      #
      # @see http://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-07#section-3
      def build_assertion(params)
        hmac_secret = params.delete(:hmac_secret)
        private_key = params.delete(:private_key)
        # Check required params for signing
        fail(ArgumentError, 'You must provide either :private_key or :hmac_secret value') unless hmac_secret || private_key
        # If requested validate parameters according to spec
        validate_required_params!(params) if params.delete(:validate)
        # Encode remaining payload according to given secret
        if hmac_secret
          JWT.encode(params, hmac_secret, 'HS256')
        elsif private_key
          JWT.encode(params, private_key, 'RS256')
        end
      end

    private

      # Validate required params according to JWT spec
      # @param [Hash] params claim set to sign
      # @raise ArgumentError if required values are not present in claim set
      def validate_required_params!(params)
        required_keys = [:iss, :sub, :aud, :exp]
        fail(ArgumentError, "You must provide values for all of #{required_keys}") unless required_keys.all? { |k| params[k] }
      end
    end
  end
end
