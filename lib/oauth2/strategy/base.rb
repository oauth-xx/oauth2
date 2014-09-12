module OAuth2
  module Strategy
    class Base
      def initialize(client)
        @client = client
      end

      # The OAuth client_id and client_secret
      #
      # @return [Hash]
      def client_params
        {'client_id' => @client.id, 'client_secret' => @client.secret}
      end

      # Returns the Authorization header value for Basic Authentication
      #
      # @param [String] The client ID
      # @param [String] the client secret
      def authorization(client_id, client_secret)
        'Basic ' + Base64.encode64(client_id + ':' + client_secret).gsub("\n", '')
      end
    end
  end
end
