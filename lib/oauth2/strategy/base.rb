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
    end
  end
end
