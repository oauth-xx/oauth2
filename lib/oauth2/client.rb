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
    # <tt>:parse_json</tt> :: If true, <tt>application/json</tt> responses will be automatically parsed.
    # <tt>:raise_errors</tt> :: Default true. When false it will then return the error status and response instead of raising an exception.
    # <tt>:ssl</tt> :: Specify SSL options for the connection.
    # <tt>:adapter</tt> :: The name of the Faraday::Adapter::* class to use, e.g. :net_http. To pass arguments
    # to the adapter pass an array here, e.g. [:action_dispatch, my_test_session]
    def initialize(client_id, client_secret, opts={})
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      @options = {  :authorize_url        => '/oauth/authorize',
                    :access_token_url     => '/oauth/access_token', 
                    :access_token_method  => :post,
                    :connection_opts      => {},
                    :parse_json           => false,
                    :raise_errors         => true }.merge(opts)
      @options[:connection_opts][:ssl] = ssl if ssl
    end
    
    def site=(value)
      @connection = nil
      @site = value
    end
    
    def connection
      @connection ||= begin
        conn = Faraday::Connection.new(site, options[:connection_opts])
        conn.build do |b|
          b.adapter(*[options[:adapter]].flatten) if options[:adapter]
        end
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
    def request(verb, url, params={}, headers={})
      if (verb == :get) || (verb == :delete)
        resp = connection.run_request(verb, url, nil, headers) do |req|
          req.params.update(params)
        end
      else
        resp = connection.run_request(verb, url, params, headers)
      end

      case resp.status
        when 200...299
          return Response.new(resp)
        when 302
          return request(verb, resp.headers['location'], params, headers)
        when 400...599
          response = Response.new(resp)
          e = Error.new(response)
          raise e if options[:raise_errors]
          response.error = e
          response
        else
          raise Error.new(Response.new(resp)), "Unhandled status code value of #{resp.status}"
      end
    end

    def web_server; OAuth2::Strategy::WebServer.new(self) end
    def password; OAuth2::Strategy::Password.new(self) end
  end
end
