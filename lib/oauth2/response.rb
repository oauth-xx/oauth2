module OAuth2
  # OAuth2::Response class 
  class Response
    attr_reader :response
    attr_accessor :error
    
    # @param [Faraday::Response] response The Faraday response instance
    def initialize(response)
      @response = response
    end
    
    # The HTTP response headers
    def headers
      response.headers
    end
    
    # The HTTP response status code
    def status
      response.status
    end
    
    # The HTTP resposne body
    def body
      response.body || ''
    end
    
    # The parsed response body.
    #   Will attempt to parse application/x-www-form-urlencoded and
    #   application/json Content-Type response bodies
    def parsed
      @parsed ||= begin
        if response.headers['Content-Type'] && 
          response.headers['Content-Type'].include?('x-www-form-urlencoded') 
          Rack::Utils.parse_query(body)
        else
          MultiJson.decode(body) rescue (body || '')
        end
      end
    end
    
  end
end