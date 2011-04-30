module OAuth2
  class Response
    attr_reader :response
    
    def initialize(response)
      @response = response
    end
    
    def headers
      self.response.headers
    end
    
    def status
      self.response.status
    end
    
    def body
      self.response.body || ''
    end
    
    def parsed
      @parsed ||= begin
        if self.response.headers['Content-Type'] && 
          self.response.headers['Content-Type'].include?('x-www-form-urlencoded') 
          Rack::Utils.parse_query(self.response.body)
        else
          MultiJson.decode(self.response.body) rescue (self.response.body || '')
        end
      end
    end
    
  end
end