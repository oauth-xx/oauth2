module OAuth2
  module Strategy
    class Base #:nodoc:
      def initialize(client)#:nodoc:
        @client = client
      end
    
      def authorize_url(options = {}) #:nodoc:
        uri = URI.parse(@client.authorize_url)
        uri.query_hash = authorize_params(options)
        uri.to_s
      end
    
      def authorize_params(options = {}) #:nodoc:
        options = options.inject({}){|h,(k,v)| h[k.to_s] = v; h}
        {'client_id' => @client.id}.merge(options)
      end
      
      def access_token_url(options = {})
        uri = URI.parse(@client.access_token_url)
        uri.query_hash = access_token_params(options)
        uri.to_s
      end
      
      def access_token_params(options = {})
        {
          'client_id' => @client.id,
          'client_secret' => @client.secret
        }.merge(options)
      end
    end
  end
end