module OAuth2
  class AccessToken
    attr_reader :client, :token, :refresh_token, :expires_in, :expires_at, :params
    attr_accessor :options

    class << self
      def from_hash(client, hash)
        self.new(client, hash.delete('access_token') || hash.delete(:access_token), hash)
      end

      def from_kvform(client, kvform)
        from_hash(client, Rack::Utils.parse_query(kvform))
      end

      def from_token_params(client, params)
        response = client.options[:token_method] == :post ?
                  client.request(:post, client.token_url, :body => params) :
                  client.request(:get, client.token_url, :params => params)
        from_hash(client, response.parsed)
      end
    end

    def initialize(client, token, args={})
      @client = client
      @token = token.to_s
      [:refresh_token, :expires_in, :expires_at].each do |arg|
        instance_variable_set("@#{arg}", args.delete(arg) || args.delete(arg.to_s))
      end
      @expires_in ||= args.delete('expires')
      @expires_in &&= @expires_in.to_i
      @expires_at ||= Time.now.to_i + @expires_in if @expires_in
      @options = {  :mode           => args.delete(:mode) || :header,
                    :header_format  => args.delete(:header_format) || 'OAuth %s',
                    :param_name     => args.delete(:param_name) || 'oauth_token' }
      @params = args
    end

    def [](key)
      @params[key]
    end

    def expires?
      !!@expires_at
    end

    def expired?
      expires? && (expires_at < Time.now.to_i)
    end

    def refresh!(params={})
      raise "A refresh_token is not available" unless refresh_token
      params.merge! :client_id      => @client.id,
                    :client_secret  => @client_secret,
                    :grant_type     => 'refresh_token',
                    :refresh_token  => refresh_token
      new_token = self.class.from_token_params(@client, params)
      new_token.options = options
      new_token
    end

    def request(verb, path, args={}, &block)
      set_token(args)
      @client.request(verb, path, args, &block)
    end

    def get(path, args={}, &block)
      request(:get, path, args, &block)
    end

    def post(path, args={}, &block)
      request(:post, path, args, &block)
    end

    def put(path, args={}, &block)
      request(:put, path, args, &block)
    end

    def delete(path, args={}, &block)
      request(:delete, path, args, &block)
    end
  
  private
    def set_token(args)
      case options[:mode]
      when :header
        args[:headers] ||= {}
        args[:headers]['Authorization'] = options[:header_format] % token
      when :query
        args[:params] ||= {}
        args[:params][options[:param_name]] = token
      when :body
        args[:body] ||= {}
        if args[:body].is_a?(Hash)
          args[:body][options[:param_name]] = token
        else
          args[:body] << "&#{options[:param_name]}=#{token}"
        end
        # TODO: support for multi-part (file uploads)
      else
        raise "invalid :mode option of #{options[:mode]}"
      end
    end
  end
end
