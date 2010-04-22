module OAuth2
  class AccessToken
    attr_reader :client, :token

    def initialize(client, token)
      @client = client
      @token = token
    end
    
    def request(verb, path, params = {}, headers = {})
      @client.request(verb, path, params.merge('access_token' => @token), headers)
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