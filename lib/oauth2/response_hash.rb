class ResponseHash < Hash
  def initialize(response)
    self.response = response
    
    body = MultiJson.decode(response.body)
    body.keys.each{|k| self[k] = body[k]}
  end
  
  attr_accessor :response
  
  def status; response.status end
  def headers; response.headers end
end