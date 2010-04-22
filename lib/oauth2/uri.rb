require 'uri'
require 'cgi'

module URI
  class Generic
    def query_hash
      CGI.parse(self.query || '').inject({}){|hash, (k,v)| hash[k] = (v.size == 1 ? v.first : v); hash}
    end
    
    def query_hash=(hash)
      self.query = hash.map{|(k,v)| "#{k}=#{CGI.escape(v)}"}.join('&')
    end
  end
end