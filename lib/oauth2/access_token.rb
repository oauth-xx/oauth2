module OAuth2
  class AccessToken
    attr_reader :client, :token, :expires_in, :expires_at, :params, :time_skew
    attr_accessor :options, :refresh_token, :response

    class << self
      # Initializes an AccessToken from a Hash
      #
      # @param [Client] the OAuth2::Client instance
      # @param [Hash] a hash of AccessToken property values
      # @return [AccessToken] the initalized AccessToken
      def from_hash(client, hash)
        hash = hash.dup
        new(client, hash.delete('access_token') || hash.delete(:access_token), hash)
      end

      # Initializes an AccessToken from a key/value application/x-www-form-urlencoded string
      #
      # @param [Client] client the OAuth2::Client instance
      # @param [String] kvform the application/x-www-form-urlencoded string
      # @return [AccessToken] the initalized AccessToken
      def from_kvform(client, kvform)
        from_hash(client, Rack::Utils.parse_query(kvform))
      end
    end

    # Initalize an AccessToken
    #
    # @param [Client] client the OAuth2::Client instance
    # @param [String] token the Access Token value
    # @param [Hash] opts the options to create the Access Token with
    # @option opts [String] :refresh_token (nil) the refresh_token value
    # @option opts [FixNum, String] :expires_in (nil) the number of seconds in which the AccessToken will expire
    # @option opts [FixNum, String] :expires_at (nil) the epoch time in seconds in which AccessToken will expire
    # @option opts [Symbol] :mode (:header) the transmission mode of the Access Token parameter value
    #    one of :header, :body or :query
    # @option opts [String] :header_format ('Bearer %s') the string format to use for the Authorization header
    # @option opts [String] :param_name ('access_token') the parameter name to use for transmission of the
    #    Access Token value in :body or :query transmission mode
    def initialize(client, token, opts = {}) # rubocop:disable Metrics/AbcSize
      local_now = Time.now.to_i
      @client = client
      @token = token.to_s
      opts = opts.dup

      [:refresh_token, :expires_in, :expires_at].each do |arg|
        instance_variable_set("@#{arg}", opts.delete(arg) || opts.delete(arg.to_s))
      end

      @expires_in ||= opts.delete('expires')
      @expires_in &&= @expires_in.to_i
      @expires_at &&= @expires_at.to_i
      @expires_at ||= local_now + @expires_in if @expires_in
      issued_at = token_payload.fetch('iat', nil)
      @time_skew = issued_at ? local_now - issued_at : 0

      @options = {:mode          => opts.delete(:mode) || :header,
                  :header_format => opts.delete(:header_format) || 'Bearer %s',
                  :param_name    => opts.delete(:param_name) || 'access_token'}
      @params = opts
    end

    # Indexer to additional params present in token response
    #
    # @param [String] key entry key to Hash
    def [](key)
      @params[key]
    end

    # Whether or not the token expires
    #
    # @return [Boolean]
    def expires?
      !!@expires_at
    end

    # Whether or not the token is expired
    #
    # @return [Boolean]
    def expired?
      expires? && (expires_at + time_skew <= Time.now.to_i)
    end

    # Refreshes the current Access Token
    #
    # @return [AccessToken] a new AccessToken
    # @note options should be carried over to the new AccessToken
    def refresh(params = {})
      raise('A refresh_token is not available') unless refresh_token
      params[:grant_type] = 'refresh_token'
      params[:refresh_token] = refresh_token
      new_token = @client.get_token(params)
      new_token.options = options
      new_token.refresh_token = refresh_token unless new_token.refresh_token
      new_token
    end
    # A compatibility alias
    # @note does not modify the receiver, so bang is not the default method
    alias refresh! refresh

    # Convert AccessToken to a hash which can be used to rebuild itself with AccessToken.from_hash
    #
    # @return [Hash] a hash of AccessToken property values
    def to_hash
      params.merge(:access_token => token, :refresh_token => refresh_token, :expires_at => expires_at)
    end

    # Make a request with the Access Token
    #
    # @param [Symbol] verb the HTTP request method
    # @param [String] path the HTTP URL path of the request
    # @param [Hash] opts the options to make the request with
    # @see Client#request
    def request(verb, path, opts = {}, &block)
      configure_authentication!(opts)
      @client.request(verb, path, opts, &block)
    end

    # Make a GET request with the Access Token
    #
    # @see AccessToken#request
    def get(path, opts = {}, &block)
      request(:get, path, opts, &block)
    end

    # Make a POST request with the Access Token
    #
    # @see AccessToken#request
    def post(path, opts = {}, &block)
      request(:post, path, opts, &block)
    end

    # Make a PUT request with the Access Token
    #
    # @see AccessToken#request
    def put(path, opts = {}, &block)
      request(:put, path, opts, &block)
    end

    # Make a PATCH request with the Access Token
    #
    # @see AccessToken#request
    def patch(path, opts = {}, &block)
      request(:patch, path, opts, &block)
    end

    # Make a DELETE request with the Access Token
    #
    # @see AccessToken#request
    def delete(path, opts = {}, &block)
      request(:delete, path, opts, &block)
    end

    # Get the headers hash (includes Authorization token)
    def headers
      {'Authorization' => options[:header_format] % token}
    end

    # For JWT tokens, this will store a Hash on the form
    # {
    #   "exp": exp,
    #   "nbf": 0,
    #   "iat": now.to_i,
    #   "iss": "https://example.com/auth/realms/issuer",
    #   "aud": "client-identifier",
    #   "sub": "subject-identifier",
    #   "typ": "Bearer",
    #   "azp": "client-identifier"
    # }
    #
    # For non-JWT tokens, an empty Hash is stored
    #
    # @return [Hash] a hash of token property values
    def token_payload
      @token_payload ||= decoded_token(:payload)
    end

    # A JWT token consists of three dot separated parts:
    #   1) header
    #   2) payload
    #   3) verify_signature
    #
    # Some access tokens are not JWT tokens,
    #   in which case nil is returned
    def decoded_token(part)
      token_chunks = token.split('.')
      selected_chunk = case part
      when :header
        token_chunks.fetch(0)
      when :payload
        token_chunks.fetch(1)
      when :verify_signature
        token_chunks.fetch(2)
      else
        raise(ArgumentError, "#{part} is not a valid token chunk, valid arguments: [:header, :payload, :verify_signature]")
      end

      JSON Base64.decode64(selected_chunk)
    rescue
      {}
    end

  private

    def configure_authentication!(opts) # rubocop:disable MethodLength, Metrics/AbcSize
      case options[:mode]
      when :header
        opts[:headers] ||= {}
        opts[:headers].merge!(headers)
      when :query
        opts[:params] ||= {}
        opts[:params][options[:param_name]] = token
      when :body
        opts[:body] ||= {}
        if opts[:body].is_a?(Hash)
          opts[:body][options[:param_name]] = token
        else
          opts[:body] << "&#{options[:param_name]}=#{token}"
        end
        # @todo support for multi-part (file uploads)
      else
        raise("invalid :mode option of #{options[:mode]}")
      end
    end
  end
end
