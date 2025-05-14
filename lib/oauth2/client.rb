# frozen_string_literal: true

require "faraday"
require "logger"

# :nocov: since coverage tracking only runs on the builds with Faraday v2
# We do run builds on Faraday v0 (and v1!), so this code is actually covered!
# This is the only nocov in the whole project!
if Faraday::Utils.respond_to?(:default_space_encoding)
  # This setting doesn't exist in faraday 0.x
  Faraday::Utils.default_space_encoding = "%20"
end
# :nocov:

module OAuth2
  ConnectionError = Class.new(Faraday::ConnectionFailed)
  TimeoutError = Class.new(Faraday::TimeoutError)

  # The OAuth2::Client class
  class Client # rubocop:disable Metrics/ClassLength
    RESERVED_PARAM_KEYS = %w[body headers params parse snaky].freeze

    include FilteredAttributes

    attr_reader :id, :secret, :site
    attr_accessor :options
    attr_writer :connection
    filtered_attributes :secret

    # Initializes a new OAuth2::Client instance using the Client ID and Client Secret registered to your application.
    #
    # @param [String] client_id the client_id value
    # @param [String] client_secret the client_secret value
    # @param [Hash] options the options to configure the client
    # @option options [String] :site the OAuth2 provider site host
    # @option options [String] :authorize_url ('/oauth/authorize') absolute or relative URL path to the Authorization endpoint
    # @option options [String] :token_url ('/oauth/token') absolute or relative URL path to the Token endpoint
    # @option options [Symbol] :token_method (:post) HTTP method to use to request token (:get, :post, :post_with_query_string)
    # @option options [Symbol] :auth_scheme (:basic_auth) the authentication scheme (:basic_auth, :request_body, :tls_client_auth, :private_key_jwt)
    # @option options [Hash] :connection_opts ({}) Hash of connection options to pass to initialize Faraday
    # @option options [Boolean] :raise_errors (true) whether to raise an OAuth2::Error on responses with 400+ status codes
    # @option options [Integer] :max_redirects (5) maximum number of redirects to follow
    # @option options [Logger] :logger (::Logger.new($stdout)) Logger instance for HTTP request/response output; requires OAUTH_DEBUG to be true
    # @option options [Class] :access_token_class (AccessToken) class to use for access tokens; you can subclass OAuth2::AccessToken, @version 2.0+
    # @option options [Hash] :ssl SSL options for Faraday
    # @yield [builder] The Faraday connection builder
    def initialize(client_id, client_secret, options = {}, &block)
      opts = options.dup
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      warn("OAuth2::Client#initialize argument `extract_access_token` will be removed in oauth2 v3. Refactor to use `access_token_class`.") if opts[:extract_access_token]
      @options = {
        authorize_url: "oauth/authorize",
        token_url: "oauth/token",
        token_method: :post,
        auth_scheme: :basic_auth,
        connection_opts: {},
        connection_build: block,
        max_redirects: 5,
        raise_errors: true,
        logger: ::Logger.new($stdout),
        access_token_class: AccessToken,
      }.merge(opts)
      @options[:connection_opts][:ssl] = ssl if ssl
    end

    # Set the site host
    #
    # @param value [String] the OAuth2 provider site host
    def site=(value)
      @connection = nil
      @site = value
    end

    # The Faraday connection object
    def connection
      @connection ||=
        Faraday.new(site, options[:connection_opts]) do |builder|
          oauth_debug_logging(builder)
          if options[:connection_build]
            options[:connection_build].call(builder)
          else
            builder.request(:url_encoded)             # form-encode POST params
            builder.adapter(Faraday.default_adapter)  # make requests with Net::HTTP
          end
        end
    end

    # The authorize endpoint URL of the OAuth2 provider
    #
    # @param [Hash] params additional query parameters
    def authorize_url(params = {})
      params = (params || {}).merge(redirection_params)
      connection.build_url(options[:authorize_url], params).to_s
    end

    # The token endpoint URL of the OAuth2 provider
    #
    # @param [Hash] params additional query parameters
    def token_url(params = nil)
      connection.build_url(options[:token_url], params).to_s
    end

    # Makes a request relative to the specified site root.
    # Updated HTTP 1.1 specification (IETF RFC 7231) relaxed the original constraint (IETF RFC 2616),
    #   allowing the use of relative URLs in Location headers.
    # @see https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.2
    #
    # @param [Symbol] verb one of :get, :post, :put, :delete
    # @param [String] url URL path of request
    # @param [Hash] opts the options to make the request with
    # @option opts [Hash] :params additional query parameters for the URL of the request
    # @option opts [Hash, String] :body the body of the request
    # @option opts [Hash] :headers http request headers
    # @option opts [Boolean] :raise_errors whether to raise an OAuth2::Error on 400+ status
    #   code response for this request.  Overrides the client instance setting.
    # @option opts [Symbol] :parse @see Response::initialize
    # @option opts [true, false] :snaky (true) @see Response::initialize
    # @yield [req] @see Faraday::Connection#run_request
    def request(verb, url, opts = {}, &block)
      response = execute_request(verb, url, opts, &block)

      case response.status
      when 301, 302, 303, 307
        opts[:redirect_count] ||= 0
        opts[:redirect_count] += 1
        return response if opts[:redirect_count] > options[:max_redirects]

        if response.status == 303
          verb = :get
          opts.delete(:body)
        end
        location = response.headers["location"]
        if location
          full_location = response.response.env.url.merge(location)
          request(verb, full_location, opts)
        else
          error = Error.new(response)
          raise(error, "Got #{response.status} status code, but no Location header was present")
        end
      when 200..299, 300..399
        # on non-redirecting 3xx statuses, just return the response
        response
      when 400..599
        if opts.fetch(:raise_errors, options[:raise_errors])
          error = Error.new(response)
          raise(error)
        end

        response
      else
        error = Error.new(response)
        raise(error, "Unhandled status code value of #{response.status}")
      end
    end

    # Retrieves an access token from the token endpoint using the specified parameters
    #
    # @param [Hash] params a Hash of params for the token endpoint
    #   * params can include a 'headers' key with a Hash of request headers
    #   * params can include a 'parse' key with the Symbol name of response parsing strategy (default: :automatic)
    #   * params can include a 'snaky' key to control snake_case conversion (default: false)
    # @param [Hash] access_token_opts options that will be passed to the AccessToken initialization
    # @param [Proc] extract_access_token (deprecated) a proc that can extract the access token from the response
    # @yield [opts] The block is passed the options being used to make the request
    # @yieldparam [Hash] opts options being passed to the http library
    #
    # @return [AccessToken, nil] the initialized AccessToken instance, or nil if token extraction fails
    #   and raise_errors is false
    #
    # @note The extract_access_token parameter is deprecated and will be removed in oauth2 v3.
    #   Use access_token_class on initialization instead.
    #
    # @example
    #   client.get_token(
    #     'grant_type' => 'authorization_code',
    #     'code' => 'auth_code_value',
    #     'headers' => {'Authorization' => 'Basic ...'}
    #   )
    def get_token(params, access_token_opts = {}, extract_access_token = nil, &block)
      warn("OAuth2::Client#get_token argument `extract_access_token` will be removed in oauth2 v3. Refactor to use `access_token_class` on #initialize.") if extract_access_token
      extract_access_token ||= options[:extract_access_token]
      parse, snaky, params, headers = parse_snaky_params_headers(params)

      request_opts = {
        raise_errors: options[:raise_errors],
        parse: parse,
        snaky: snaky,
      }
      if options[:token_method] == :post

        # NOTE: If proliferation of request types continues, we should implement a parser solution for Request,
        #       just like we have with Response.
        request_opts[:body] = if headers["Content-Type"] == "application/json"
          params.to_json
        else
          params
        end

        request_opts[:headers] = {"Content-Type" => "application/x-www-form-urlencoded"}
      else
        request_opts[:params] = params
        request_opts[:headers] = {}
      end
      request_opts[:headers].merge!(headers)
      response = request(http_method, token_url, request_opts, &block)

      # In v1.4.x, the deprecated extract_access_token option retrieves the token from the response.
      # We preserve this behavior here, but a custom access_token_class that implements #from_hash
      # should be used instead.
      if extract_access_token
        parse_response_legacy(response, access_token_opts, extract_access_token)
      else
        parse_response(response, access_token_opts)
      end
    end

    # The HTTP Method of the request
    # @return [Symbol] HTTP verb, one of :get, :post, :put, :delete
    def http_method
      http_meth = options[:token_method].to_sym
      return :post if http_meth == :post_with_query_string

      http_meth
    end

    # The Authorization Code strategy
    #
    # @see http://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-15#section-4.1
    def auth_code
      @auth_code ||= OAuth2::Strategy::AuthCode.new(self)
    end

    # The Implicit strategy
    #
    # @see http://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-26#section-4.2
    def implicit
      @implicit ||= OAuth2::Strategy::Implicit.new(self)
    end

    # The Resource Owner Password Credentials strategy
    #
    # @see http://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-15#section-4.3
    def password
      @password ||= OAuth2::Strategy::Password.new(self)
    end

    # The Client Credentials strategy
    #
    # @see http://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-15#section-4.4
    def client_credentials
      @client_credentials ||= OAuth2::Strategy::ClientCredentials.new(self)
    end

    def assertion
      @assertion ||= OAuth2::Strategy::Assertion.new(self)
    end

    # The redirect_uri parameters, if configured
    #
    # The redirect_uri query parameter is OPTIONAL (though encouraged) when
    # requesting authorization. If it is provided at authorization time it MUST
    # also be provided with the token exchange request.
    #
    # Providing the :redirect_uri to the OAuth2::Client instantiation will take
    # care of managing this.
    #
    # @api semipublic
    #
    # @see https://datatracker.ietf.org/doc/html/rfc6749#section-4.1
    # @see https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3
    # @see https://datatracker.ietf.org/doc/html/rfc6749#section-4.2.1
    # @see https://datatracker.ietf.org/doc/html/rfc6749#section-10.6
    # @return [Hash] the params to add to a request or URL
    def redirection_params
      if options[:redirect_uri]
        {"redirect_uri" => options[:redirect_uri]}
      else
        {}
      end
    end

  private

    # Processes and transforms the input parameters for OAuth requests
    #
    # @param [Hash] params the input parameters to process
    # @option params [Symbol, nil] :parse (:automatic) parsing strategy for the response
    # @option params [Boolean] :snaky (true) whether to convert response keys to snake_case
    # @option params [Hash] :headers HTTP headers for the request
    #
    # @return [Array<(Symbol, Boolean, Hash, Hash)>] Returns an array containing:
    #   - [Symbol, nil] parse strategy
    #   - [Boolean] snaky flag for response key transformation
    #   - [Hash] processed parameters
    #   - [Hash] HTTP headers
    #
    # @api private
    def parse_snaky_params_headers(params)
      params = params.map do |key, value|
        if RESERVED_PARAM_KEYS.include?(key)
          [key.to_sym, value]
        else
          [key, value]
        end
      end.to_h
      parse = params.key?(:parse) ? params.delete(:parse) : Response::DEFAULT_OPTIONS[:parse]
      snaky = params.key?(:snaky) ? params.delete(:snaky) : Response::DEFAULT_OPTIONS[:snaky]
      params = authenticator.apply(params)
      # authenticator may add :headers, and we remove them here
      headers = params.delete(:headers) || {}
      [parse, snaky, params, headers]
    end

    # Executes an HTTP request with error handling and response processing
    #
    # @param [Symbol] verb the HTTP method to use (:get, :post, :put, :delete)
    # @param [String] url the URL for the request
    # @param [Hash] opts the request options
    # @option opts [Hash] :body the request body
    # @option opts [Hash] :headers the request headers
    # @option opts [Hash] :params the query parameters to append to the URL
    # @option opts [Symbol, nil] :parse (:automatic) parsing strategy for the response
    # @option opts [Boolean] :snaky (true) whether to convert response keys to snake_case
    #
    # @yield [req] gives access to the request object before sending
    # @yieldparam [Faraday::Request] req the request object that can be modified
    #
    # @return [OAuth2::Response] the response wrapped in an OAuth2::Response object
    #
    # @raise [OAuth2::ConnectionError] when there's a network error
    # @raise [OAuth2::TimeoutError] when the request times out
    #
    # @api private
    def execute_request(verb, url, opts = {})
      url = connection.build_url(url).to_s

      begin
        response = connection.run_request(verb, url, opts[:body], opts[:headers]) do |req|
          req.params.update(opts[:params]) if opts[:params]
          yield(req) if block_given?
        end
      rescue Faraday::ConnectionFailed => e
        raise ConnectionError, e
      rescue Faraday::TimeoutError => e
        raise TimeoutError, e
      end

      parse = opts.key?(:parse) ? opts.delete(:parse) : Response::DEFAULT_OPTIONS[:parse]
      snaky = opts.key?(:snaky) ? opts.delete(:snaky) : Response::DEFAULT_OPTIONS[:snaky]

      Response.new(response, parse: parse, snaky: snaky)
    end

    # Returns the authenticator object
    #
    # @return [Authenticator] the initialized Authenticator
    def authenticator
      Authenticator.new(id, secret, options[:auth_scheme])
    end

    # Parses the OAuth response and builds an access token using legacy extraction method
    #
    # @deprecated Use {#parse_response} instead
    #
    # @param [OAuth2::Response] response the OAuth2::Response from the token endpoint
    # @param [Hash] access_token_opts options to pass to the AccessToken initialization
    # @param [Proc] extract_access_token proc to extract the access token from response
    #
    # @return [AccessToken, nil] the initialized AccessToken if successful, nil if extraction fails
    #   and raise_errors option is false
    #
    # @raise [OAuth2::Error] if response indicates an error and raise_errors option is true
    #
    # @api private
    def parse_response_legacy(response, access_token_opts, extract_access_token)
      access_token = build_access_token_legacy(response, access_token_opts, extract_access_token)

      return access_token if access_token

      if options[:raise_errors]
        error = Error.new(response)
        raise(error)
      end

      nil
    end

    # Parses the OAuth response and builds an access token using the configured access token class
    #
    # @param [OAuth2::Response] response the OAuth2::Response from the token endpoint
    # @param [Hash] access_token_opts options to pass to the AccessToken initialization
    #
    # @return [AccessToken] the initialized AccessToken instance
    #
    # @raise [OAuth2::Error] if the response is empty/invalid and the raise_errors option is true
    #
    # @api private
    def parse_response(response, access_token_opts)
      access_token_class = options[:access_token_class]
      data = response.parsed

      unless data.is_a?(Hash) && !data.empty?
        return unless options[:raise_errors]

        error = Error.new(response)
        raise(error)
      end

      build_access_token(response, access_token_opts, access_token_class)
    end

    # Creates an access token instance from response data using the specified token class
    #
    # @param [OAuth2::Response] response the OAuth2::Response from the token endpoint
    # @param [Hash] access_token_opts additional options to pass to the AccessToken initialization
    # @param [Class] access_token_class the class that should be used to create access token instances
    #
    # @return [AccessToken] an initialized AccessToken instance with response data
    #
    # @note If the access token class responds to response=, the full response object will be set
    #
    # @api private
    def build_access_token(response, access_token_opts, access_token_class)
      access_token_class.from_hash(self, response.parsed.merge(access_token_opts)).tap do |access_token|
        access_token.response = response if access_token.respond_to?(:response=)
      end
    end

    # Builds an access token using a legacy extraction proc
    #
    # @deprecated Use {#build_access_token} instead
    #
    # @param [OAuth2::Response] response the OAuth2::Response from the token endpoint
    # @param [Hash] access_token_opts additional options to pass to the access token extraction
    # @param [Proc] extract_access_token a proc that takes client and token hash as arguments
    #   and returns an access token instance
    #
    # @return [AccessToken, nil] the access token instance if extraction succeeds,
    #   nil if any error occurs during extraction
    #
    # @api private
    def build_access_token_legacy(response, access_token_opts, extract_access_token)
      extract_access_token.call(self, response.parsed.merge(access_token_opts))
    rescue StandardError
      nil
    end

    def oauth_debug_logging(builder)
      builder.response(:logger, options[:logger], bodies: true) if ENV["OAUTH_DEBUG"] == "true"
    end
  end
end
