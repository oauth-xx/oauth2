module OAuth2
  module Strategy
    class Base
      def initialize(client)
        @client = client
      end

      def authorize_params(params={})
        client_params.merge(params)
      end

      def client_params
        { 'client_id'     => @client.id,
          'client_secret' => @client.secret }
      end
    end
  end
end
