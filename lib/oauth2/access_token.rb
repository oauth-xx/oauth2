module OAuth2
  class AccessToken
    attr_reader :client, :token, :refresh_token

    def initialize(client, token, refresh_token = nil)
      @client = client
      @token = token
      @refresh_token = refresh_token
    end
    
    def request(verb, path, params = {}, headers = {})
      @client.request(verb, path, params.merge('access_token' => @token), headers.merge('Authorization' => "Token token=\"#{@token}\""))
    end
    
    def get(path, params = {}, headers = {})
      request(:get, path, params, headers)
    end
    
    def post(path, params = {}, headers = {})
      request(:post, path, params, headers)
    end
    
    def put(path, params = {}, headers = {})
      request(:put, path, params, headers)
    end
    
    def delete(path, params = {}, headers = {})
      request(:delete, path, params, headers)
    end
  end
end
