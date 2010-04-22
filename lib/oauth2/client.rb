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
    # <tt>:authorize_path</tt> :: Specify the path to the authorization endpoint.
    # <tt>:authorize_url</tt> :: Specify a full URL of the authorization endpoint.
    # <tt>:access_token_path</tt> :: Specify the path to the access token endpoint.
    # <tt>:access_token_url</tt> :: Specify the full URL of the access token endpoint.
    def initialize(client_id, client_secret, opts = {})
      self.id         = client_id
      self.secret     = client_secret
      self.site       = opts.delete(:site) if opts[:site]
      self.options    = opts
      self.connection = Faraday::Connection.new(site)
    end
    
    def authorize_url(params = nil)
      path = options[:authorize_url] || options[:authorize_path] || "/oauth/authorize"
      connection.build_url(path, params).to_s
    end
    
    def access_token_url(params = nil)
      path = options[:access_token_url] || options[:access_token_path] || "/oauth/access_token"
      connection.build_url(path, params).to_s
    end
    
    def request(verb, url, params = {}, headers = {})
      resp = connection.run_request(verb, url, nil, headers) do |req|
        req.params.update(params)
      end
      resp.status ? resp.body : resp
    end
    
    def web_server; OAuth2::Strategy::WebServer.new(self) end
  end
end