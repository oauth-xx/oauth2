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
        case @client.options[:client_auth]
        when :params
          {'client_id' => @client.id, 'client_secret' => @client.secret}
        when :http_basic
          auth_value = 'Basic ' + Base64.encode64(@client.id + ':' + @client.secret)
          {:headers => {'Authorization' => auth_value}}
        end
      end
    end
  end
end
