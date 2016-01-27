require 'jwt'

module OAuth2
  module Strategy
    # The JWT Bearer Assertion Strategy
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-06#section-2.1
    #
    # Sample usage:
    #   client = OAuth2::Client.new(client_id, client_secret,
    #                               :site => 'http://localhost:8080')
    #
    #   params = {:hmac_secret => "some secret",
    #             # or :private_key => "private key string",
    #             :iss => "http://localhost:3001",
    #             :sub => "me@here.com",
    #             :exp => Time.now.utc.to_i + 3600,
    #             :algorithm => "HS256"}
    #
    #   access = client.assertion.get_token(params)
    #   access.token                 # actual access_token string
    #   access.get("/api/stuff")     # making api calls with access token in header
    #
    class JWTBearer < Base
      # Not used for this strategy
      #
      # @raise [NotImplementedError]
      def authorize_url
        fail NotImplementedError, 'The authorization endpoint is not used in this strategy'
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
      #   params :algorithm, signing algorithm, optional
      #
      # @param [Hash] opts options
      def get_token(params = {}, opts = {})
        hash = build_request(params)
        @client.get_token(hash, opts.merge('refresh_token' => nil))
      end

      def build_request(params)
        assertion = build_assertion(params)
        { grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          assertion: assertion,
          scope: params[:scope]
        }.merge(client_params)
      end

      def build_assertion(params)
        claims = { iss: params[:iss],
                   aud: params[:aud],
                   sub: params[:sub],
                   exp: params[:exp]
        }
        if params[:hmac_secret]
          jwt_assertion = JWT.encode(claims, params[:hmac_secret], params[:algorithm] || 'HS256')
        elsif params[:private_key]
          jwt_assertion = JWT.encode(claims, params[:private_key], params[:algorithm] || 'RS256')
        end
      end
    end
  end
end