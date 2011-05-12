require 'multi_json'

module OAuth2
  module Strategy
    class Password < Base
      def authorize_url
        raise NotImplementedError, "The authorization endpoint is not used in this strategy"
      end
      
      def get_token(username, password, params={})
        params = {  'grant_type'  => 'password',
                    'username'    => username,
                    'password'    => password }.merge(client_params).merge(params)
        OAuth2::AccessToken.from_token_params(@client, params)
      end
    end
  end
end
