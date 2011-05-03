module OAuth2
  class AccessToken
    attr_reader :client, :token, :refresh_token, :expires_in, :expires_at, :params
    attr_accessor :token_param

    def initialize(client, token, refresh_token=nil, expires_in=nil, params={})
      @client = client
      @token = token.to_s
      @refresh_token = refresh_token.to_s
      @expires_in = (expires_in.nil? || expires_in == '') ? nil : expires_in.to_i
      @expires_at = Time.now + @expires_in if @expires_in
      @params = params
      @token_param = 'oauth_token'
    end

    def [](key)
      @params[key]
    end

    # True if the token in question has an expiration time.
    def expires?
      !!@expires_in
    end

    def expired?
      expires? && expires_at < Time.now
    end

    def request(verb, path, options={}, &block)
      options[:headers] ||= {}
      options[:headers].merge! 'Authorization' => "OAuth #{@token}"
      @client.request(verb, path, options, &block)
    end

    def get(path, options={}, &block)
      request(:get, path, options, &block)
    end

    def post(path, options={}, &block)
      request(:post, path, options, &block)
    end

    def put(path, options={}, &block)
      request(:put, path, options, &block)
    end

    def delete(path, options={}, &block)
      request(:delete, path, options, &block)
    end
  end
end
