module OAuth2
  module Strategy
    class WebServer < Base
      def authorize_params(options = {}) #:nodoc:
        super(options).merge('type' => 'web_server')
      end
      
      def access_token(code, options = {})
        response = @client.request(:get, @client.access_token_url, access_token_params(code, options))
        params   = Rack::Utils.parse_query(response)
        token    = params['access_token']
        OAuth2::AccessToken.new(@client, token)
      end
      
      def access_token_params(code, options = {})
        super(options).merge({
          'type' => 'web_server',
          'code' => code
        })
      end
    end
  end
end