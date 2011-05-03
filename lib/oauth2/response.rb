module OAuth2
  class Response
    attr_reader :response
    attr_accessor :error
    
    def initialize(response)
      @response = response
    end
    
    def headers
      response.headers
    end
    
    def status
      response.status
    end
    
    def body
      response.body || ''
    end
    
    def parsed
      @parsed ||= begin
        if response.headers['Content-Type'] && 
          response.headers['Content-Type'].include?('x-www-form-urlencoded') 
          Rack::Utils.parse_query(response.body)
        else
          MultiJson.decode(response.body) rescue (response.body || '')
        end
      end
    end
    
  end
end