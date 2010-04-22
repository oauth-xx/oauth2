require 'net/https'

module OAuth2
  class Client
    attr_accessor :id, :secret, :site, :options
    
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
      self.id = client_id
      self.secret = client_secret
      self.site = opts.delete(:site) if opts[:site]
      self.options = opts
    end
    
    def authorize_url
      return options[:authorize_url] if options[:authorize_url]

      uri = URI.parse(site)
      uri.path = options[:authorize_path] || "/oauth/authorize"
      uri.to_s
    end
    
    def access_token_url
      return options[:access_token_url] if options[:access_token_url]

      uri = URI.parse(site)
      uri.path = options[:access_token_path] || "/oauth/access_token"
      uri.to_s
    end
    
    def request(verb, url_or_path, params = {}, headers = {})
      if url_or_path[0..3] == 'http'
        uri = URI.parse(url_or_path)
        path = uri.path
      else
        uri = URI.parse(self.site)
        path = (uri.path + url_or_path).gsub('//','/')
      end
      
      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = (uri.scheme == 'https')
      
      net.start do |http|
        if verb == :get
          uri.query_hash = uri.query_hash.merge(params)
          path += "?#{uri.query}"
        end
        
        req = Net::HTTP.const_get(verb.to_s.capitalize).new(path, headers)
        
        unless verb == :get
          req.set_form_data(params)
        end
        
        response = http.request(req)
        
        case response
          when Net::HTTPSuccess
            response.body
          when Net::HTTPUnauthorized
            e = OAuth2::AccessDenied.new("Received HTTP 401 when retrieving access token.")
            e.response = response
            raise e
          else
            e = OAuth2::HTTPError.new("Received HTTP #{response.code} when retrieving access token.")
            e.response = response
            raise e
        end
      end
    end
    
    def web_server; OAuth2::Strategy::WebServer.new(self) end
  end
end