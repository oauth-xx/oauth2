require 'faraday'

module OAuth2
  class Client
    attr_accessor :id, :secret, :site, :connection, :options

    # Instantiate a new OAuth 2.0 client using the
    # client ID and client secret registered to your
    # application.
    #
    # Options:
    #
    # <tt>:site</tt> :: Specify a base URL for your OAuth 2.0 client.
    # <tt>:authorize_url</tt> :: Specify a full URL of the authorization endpoint.
    # <tt>:access_token_url</tt> :: Specify the full URL of the access token endpoint.
    # <tt>:access_token_method</tt> :: Specify the method to use for token endpoints, can be :get or :post
    # (note: for Facebook this should be :get and for Google this should be :post)
    # <tt>:raise_errors</tt> :: Default true. When false it will then return the error status and response instead of raising an exception.
    # <tt>:ssl</tt> :: Specify SSL options for the connection.
    # <tt>&block</tt> :: Faraday connection build block
    def initialize(client_id, client_secret, opts={}, &block)
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      @options = {  :authorize_url        => '/oauth/authorize',
                    :access_token_url     => '/oauth/access_token', 
                    :access_token_method  => :post,
                    :connection_opts      => {},
                    :connection_build     => block,
                    :max_redirects        => 5,
                    :raise_errors         => true }.merge(opts)
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

    def access_token_url(params=nil)
      connection.build_url(options[:access_token_url], params).to_s
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
          raise e if options[:raise_errors]
          response.error = e
          response
        else
          raise Error.new(response), "Unhandled status code value of #{response.status}"
        end
      end
    end

    def web_server; OAuth2::Strategy::WebServer.new(self) end
    def password; OAuth2::Strategy::Password.new(self) end
end
