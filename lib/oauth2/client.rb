# frozen_string_literal: true

require 'faraday'
require 'logger'

module OAuth2
  ConnectionError = Class.new(Faraday::ConnectionFailed)
  # The OAuth2::Client class
  class Client # rubocop:disable Metrics/ClassLength
    RESERVED_PARAM_KEYS = %w[headers parse].freeze

    attr_reader :id, :secret, :site
    attr_accessor :options
    attr_writer :connection

    # Instantiate a new OAuth 2.0 client using the
    # Client ID and Client Secret registered to your
    # application.
    #
    # @param [String] client_id the client_id value
    # @param [String] client_secret the client_secret value
    # @param [Hash] options the options to create the client with
    # @option options [String] :site the OAuth2 provider site host
    # @option options [String] :redirect_uri the absolute URI to the Redirection Endpoint for use in authorization grants and token exchange
    # @option options [String] :authorize_url ('oauth/authorize') absolute or relative URL path to the Authorization endpoint
    # @option options [String] :token_url ('oauth/token') absolute or relative URL path to the Token endpoint
    # @option options [Symbol] :token_method (:post) HTTP method to use to request token (:get or :post)
    # @option options [Symbol] :auth_scheme (:basic_auth) HTTP method to use to authorize request (:basic_auth or :request_body)
    # @option options [Hash] :connection_opts ({}) Hash of connection options to pass to initialize Faraday with
    # @option options [FixNum] :max_redirects (5) maximum number of redirects to follow
    # @option options [Boolean] :raise_errors (true) whether or not to raise an OAuth2::Error on responses with 400+ status codes
    # @option options [Logger] :logger (::Logger.new($stdout)) which logger to use when OAUTH_DEBUG is enabled
    # @option options [Proc] (DEPRECATED) :extract_access_token  proc that extracts the access token from the response
    # @yield [builder] The Faraday connection builder
    def initialize(client_id, client_secret, options = {}, &block)
      opts = options.dup
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      @options = {:authorize_url => 'oauth/authorize',
                  :token_url => 'oauth/token',
                  :token_method => :post,
                  :auth_scheme => :request_body,
                  :connection_opts => {},
                  :connection_build => block,
                  :max_redirects => 5,
                  :raise_errors => true,
                  :extract_access_token => DEFAULT_EXTRACT_ACCESS_TOKEN, # DEPRECATED
                  :logger => ::Logger.new($stdout)}.merge(opts)
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
            builder.request :url_encoded             # form-encode POST params
            builder.adapter Faraday.default_adapter  # make requests with Net::HTTP
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
    #
    # @param [Symbol] verb one of :get, :post, :put, :delete
    # @param [String] url URL path of request
    # @param [Hash] opts the options to make the request with
    # @option opts [Hash] :params additional query parameters for the URL of the request
    # @option opts [Hash, String] :body the body of the request
    # @option opts [Hash] :headers http request headers
    # @option opts [Boolean] :raise_errors whether or not to raise an OAuth2::Error on 400+ status
    #   code response for this request.  Will default to client option
    # @option opts [Symbol] :parse @see Response::initialize
    # @yield [req] The Faraday request
    def request(verb, url, opts = {}) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      url = connection.build_url(url).to_s

      begin
        response = connection.run_request(verb, url, opts[:body], opts[:headers]) do |req|
          req.params.update(opts[:params]) if opts[:params]
          yield(req) if block_given?
        end
      rescue Faraday::ConnectionFailed => e
        raise ConnectionError, e
      end

      response = Response.new(response, :parse => opts[:parse])

      case response.status
      when 301, 302, 303, 307
        opts[:redirect_count] ||= 0
        opts[:redirect_count] += 1
        return response if opts[:redirect_count] > options[:max_redirects]

        if response.status == 303
          verb = :get
          opts.delete(:body)
        end
        location = response.headers['location']
        if location
          request(verb, location, opts)
        else
          error = Error.new(response)
          raise(error, "Got #{response.status} status code, but no Location header was present")
        end
      when 200..299, 300..399
        # on non-redirecting 3xx statuses, just return the response
        response
      when 400..599
        error = Error.new(response)
        raise(error) if opts.fetch(:raise_errors, options[:raise_errors])

        response.error = error
        response
      else
        error = Error.new(response)
        raise(error, "Unhandled status code value of #{response.status}")
      end
    end

    # Initializes an AccessToken by making a request to the token endpoint
    #
    # @param params [Hash] a Hash of params for the token endpoint
    # @param access_token_opts [Hash] access token options, to pass to the AccessToken object
    # @param access_token_class [Class] class of access token for easier subclassing OAuth2::AccessToken
    # @return [AccessToken] the initialized AccessToken
    def get_token(params, access_token_opts = {}, extract_access_token = options[:extract_access_token]) # # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity Metrics/AbcSize, Metrics/MethodLength
      params = params.map do |key, value|
        if RESERVED_PARAM_KEYS.include?(key)
          [key.to_sym, value]
        else
          [key, value]
        end
      end
      params = Hash[params]

      params = authenticator.apply(params)
      opts = {:raise_errors => options[:raise_errors], :parse => params.delete(:parse)}
      headers = params.delete(:headers) || {}
      if options[:token_method] == :post
        opts[:body] = params
        opts[:headers] = {'Content-Type' => 'application/x-www-form-urlencoded'}
      else
        opts[:params] = params
        opts[:headers] = {}
      end
      opts[:headers] = opts[:headers].merge(headers)
      http_method = options[:token_method]
      response = request(http_method, token_url, opts)

      access_token = begin
        build_access_token(response, access_token_opts, extract_access_token)
      rescue StandardError
        nil
      end

      response_contains_token = access_token || (
                                  response.parsed.is_a?(Hash) &&
                                  (response.parsed['access_token'] || response.parsed['id_token'])
                                )

      if options[:raise_errors] && !response_contains_token
        error = Error.new(response)
        raise(error)
      elsif !response_contains_token
        return nil
      end

      access_token
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
        {'redirect_uri' => options[:redirect_uri]}
      else
        {}
      end
    end

    DEFAULT_EXTRACT_ACCESS_TOKEN = proc do |client, hash|
      token = hash.delete('access_token') || hash.delete(:access_token)
      token && AccessToken.new(client, token, hash)
    end

  private

    # Returns the authenticator object
    #
    # @return [Authenticator] the initialized Authenticator
    def authenticator
      Authenticator.new(id, secret, options[:auth_scheme])
    end

    # Builds the access token from the response of the HTTP call
    #
    # @return [AccessToken] the initialized AccessToken
    def build_access_token(response, access_token_opts, extract_access_token)
      parsed_response = response.parsed.dup
      return unless parsed_response.is_a?(Hash)

      hash = parsed_response.merge(access_token_opts)

      # Provide backwards compatibility for old AccessToken.form_hash pattern
      # Will be deprecated in 2.x
      if extract_access_token.is_a?(Class) && extract_access_token.respond_to?(:from_hash)
        extract_access_token.from_hash(self, hash)
      else
        extract_access_token.call(self, hash)
      end
    end

    def oauth_debug_logging(builder)
      builder.response :logger, options[:logger], :bodies => true if ENV['OAUTH_DEBUG'] == 'true'
    end
  end
end
