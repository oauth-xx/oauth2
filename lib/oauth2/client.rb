require 'faraday'

module OAuth2
  class Client
    attr_reader :id, :secret
    attr_accessor :site, :connection, :options

    # Instantiate a new OAuth 2.0 client using the
    # Client ID and Client Secret registered to your
    # application.
    #
    # @param [String] client_id the client_id value
    # @param [String] client_secret the client_secret value
    # @params [Hash] opts the options to create the client with
    # @options opts [String] :authorize_url absolute or relative URL path to the Authorization endpoint
    # @options opts [String] :token_url absolute or relative URL path to the Token endpoint
    # @options opts [Symbol] :token_method HTTP method to use to request token (:get or :post)
    # @options opts [Hash] :connection_opts Hash of connection options to pass to initialize Faraday with
    # @options opts [FixNum] :max_redirects maximum number of redirects to follow (default is 5)
    # @options opts [Boolean] :raise_errors whether or not to raise an OAuth2::Error 
    #  on responses with 400+ status codes
    # @yield 
    def initialize(client_id, client_secret, opts={}, &block)
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      @options = {  :authorize_url    => '/oauth/authorize',
                    :token_url        => '/oauth/token', 
                    :token_method     => :post,
                    :connection_opts  => {},
                    :connection_build => block,
                    :max_redirects    => 5,
                    :raise_errors     => true }.merge(opts)
      @options[:connection_opts][:ssl] = ssl if ssl
    end
    
    
    def site=(value)
      @connection = nil
      @site = value
    end
    
    def connection
      @connection ||= begin
        conn = Faraday.new(site, options[:connection_opts])
        conn.build do |b|
          options[:connection_build].call(b)
        end if options[:connection_build]
        conn
      end
    end

    def authorize_url(params=nil)
      connection.build_url(options[:authorize_url], params).to_s
    end

    def token_url(params=nil)
      connection.build_url(options[:token_url], params).to_s
    end

    # Makes a request relative to the specified site root.
    def request(verb, url, args={})
      url = self.connection.build_url(url, args[:params]).to_s
      
      response = connection.run_request(verb, url, args[:body], args[:headers]) do |req|
        yield(req) if block_given?
      end
      response = Response.new(response)
      
      case response.status
        when 200...299
          response
        when 300...307
          args[:redirect_count] ||= 0
          args[:redirect_count] += 1
          return response if args[:redirect_count] > options[:max_redirects]
          if response.status == 303
            verb = :get
            args.delete(:body)
          end
          request(verb, response.headers['location'], args)
        when 400...599
          e = Error.new(response)
          raise e if args[:raise_errors] || options[:raise_errors]
          response.error = e
          response
        else
          raise Error.new(response), "Unhandled status code value of #{response.status}"
        end
      end
    end

    def auth_code; OAuth2::Strategy::AuthCode.new(self) end
    def password; OAuth2::Strategy::Password.new(self) end
end
