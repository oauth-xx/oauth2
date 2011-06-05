require 'multi_json'

module OAuth2
  # OAuth2::Response class
  class Response
    attr_reader :response
    attr_accessor :error, :options

    # Initializes a Response instance
    #
    # @param [Faraday::Response] response The Faraday response instance
    # @param [Hash] opts options in which to initialize the instance
    # @option opts [Symbol] :parse (:automatic) how to parse the response body.  one of :url (for x-www-form-urlencoded),
    #   :json, or :automatic (determined by Content-Type response header)
    def initialize(response, opts={})
      @response = response
      @options = {:parse => :automatic}.merge(opts)
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
        case options[:parse]
        when :url
          Rack::Utils.parse_query(body)
        when :json
          MultiJson.decode(body)
        else
          if response.headers['Content-Type'] &&
            response.headers['Content-Type'].include?('x-www-form-urlencoded')
            Rack::Utils.parse_query(body)
          else
            MultiJson.decode(body) rescue body
          end
        end
      end
    end
  end
end
