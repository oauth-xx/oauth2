require 'jwt'

module OAuth2
  module Strategy
    # The Client Assertion Strategy
    #
    # @see https://tools.ietf.org/html/rfc7523
    #
    # Sample usage:
    #   client = OAuth2::Client.new(client_id, client_secret,
    #                               :site => 'http://localhost:8080',
    #                               :auth_scheme => :request_body)
    #
    #   claimset = {
    #     :iss => "http://localhost:3001",
    #     :aud => "http://localhost:8080/oauth2/token"
    #     :sub => "me@example.com",
    #     :exp => Time.now.utc.to_i + 3600
    #   }
    #
    #   access = client.assertion.get_token(claimset, 'HS256', 'secret_key')
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
      # @param [Hash] claims the hash representation of the claims that should be encoded as a JWT (JSON Web Token)
      # 
      # For reading on JWT and claim keys:
      #   @see https://github.com/jwt/ruby-jwt
      #   @see https://tools.ietf.org/html/rfc7519#section-4.1
      #   @see https://www.iana.org/assignments/jwt/jwt.xhtml
      # 
      # There are many possible claim keys, and applications may ask for their own custom keys.
      # Some typically required ones:
      # 
      #   :iss (issuer)
      #   :aud (audience)
      #   :sub (subject) -- formerly :prn https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-06#appendix-F   
      #   :exp, (expiration time) -- in seconds, e.g. Time.now.utc.to_i + 3600     
      # 
      # @param [String] algorithm the algorithm with which you would like the JWT to be encoded.
      # @param [Object] key the key with which you would like to encode the JWT
      # 
      # These two arguments are passed directly to `JWT.encode`.  For supported encoding arguments:
      #   @see https://github.com/jwt/ruby-jwt#algorithms-and-usage
      #   @see https://tools.ietf.org/html/rfc7518#section-3.1
      # 
      # The object type of `key` may depend on the value of `algorithm`.  Sample arguments:
      #   client.assertion.get_token(claimset, 'HS256', 'secret_key')
      #   client.assertion.get_token(claimset, 'RS256', OpenSSL::PKCS12.new(File.read('my_key.p12'), 'not_secret'))
      # 
      # @param [Hash] request_opts options that will be used to assemble the request
      # @option request_opts [String] :scope the url parameter `scope` that may be required by some endpoints
      #   @see https://tools.ietf.org/html/rfc7521#section-4.1
      # 
      # @param [Hash] response_opts this will be merged with the token response to create the AccessToken object
      #   @see the access_token_opts argument to Client#get_token 
      
      def get_token(claims, algorithm, key, request_opts = {}, response_opts = {})
        assertion = build_assertion(claims, algorithm, key)
        params = build_request(assertion, request_opts)
        
        @client.get_token(params, response_opts.merge('refresh_token' => nil))
      end

    private

      def build_request(assertion, request_opts = {})
        {
          :grant_type => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          :assertion => assertion,
        }.merge(request_opts)
      end

      def build_assertion(claims, algorithm, key)
        JWT.encode(claims, key, algorithm)
      end
    end
  end
end
