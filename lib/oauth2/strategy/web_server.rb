require 'multi_json'

module OAuth2
  module Strategy
    class WebServer < Base
      def authorize_params(options={}) #:nodoc:
        super(options).merge('response_type' => 'code')
      end

      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_access_token(code, options={})
        response = @client.request(:get, @client.access_token_url, access_token_params(code, 'access', options))

        if response.is_a? Hash
          params = response
        else
          params = MultiJson.decode(response) rescue nil
          # the ActiveSupport JSON parser won't cause an exception when
          # given a formencoded string, so make sure that it was
          # actually parsed in an Hash. This covers even the case where
          # it caused an exception since it'll still be nil.
          params = Rack::Utils.parse_query(response) unless params.is_a? Hash
        end

        access = params.delete('access_token')
        refresh = params.delete('refresh_token')
        # params['expires'] is only for Facebook
        expires_in = params.delete('expires_in') || params.delete('expires')
        OAuth2::AccessToken.new(@client, access, refresh, expires_in, params)
      end

      def refresh_access_token(refresh_token, options={})
        response = @client.request(:post, @client.access_token_url, access_token_params(refresh_token, 'refresh', options))

        if response.is_a? Hash
          params = response
        else
          params = MultiJson.decode(response) rescue nil
          # the ActiveSupport JSON parser won't cause an exception when
          # given a formencoded string, so make sure that it was
          # actually parsed in an Hash. This covers even the case where
          # it caused an exception since it'll still be nil.
          params = Rack::Utils.parse_query(response) unless params.is_a? Hash
        end

        access = params.delete('access_token')
        expires_in = params.delete('expires_in') || params.delete('expires')
        OAuth2::AccessToken.new(@client, access, refresh_token, expires_in, params)
      end

      def access_token_params(code, type, options={}) #:nodoc:
        if type == 'access'
          super(options).merge({
                                 'grant_type' => 'authorization_code',
                                 'code' => code,
                               })
        elsif type == 'refresh'
          super(options).merge({
                                 'grant_type' => 'refresh_token',
                                 'refresh_token' => code,
                               })
        end

      end
    end
  end
end
