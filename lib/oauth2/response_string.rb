# This special String class is returned from HTTP requests
# and contains the original full response along with convenience
# methods for accessing the HTTP status code and headers. It
# is returned from all access token requests.
class ResponseString < String
  def initialize(response)
    super(response.body)
    self.response = response
  end
    
  attr_accessor :response
  
  def status; response.status end
  def headers; response.headers end
end