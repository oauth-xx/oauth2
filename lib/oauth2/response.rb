require 'multi_json'

module OAuth2
  # OAuth2::Response class
  class Response
    attr_reader :response
    attr_accessor :error, :options

    # Adds a new content type parser.
    #
    # @param [Symbol] key A descriptive symbol key such as :json or :query.
    # @param [Array] One or more mime types to which this parser applies.
    # @yield [String] A block returning parsed content.
    def self.register_parser(key, mime_types, &block)
      key = key.to_sym
      PARSERS[key] = block
      Array(mime_types).each do |mime_type|
        CONTENT_TYPES[mime_type] = key
      end
    end

    # Initializes a Response instance
    #
    # @param [Faraday::Response] response The Faraday response instance
    # @param [Hash] opts options in which to initialize the instance
    # @option opts [Symbol] :parse (:automatic) how to parse the response body.  one of :query (for x-www-form-urlencoded),
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

    # Procs that, when called, will parse a response body according
    # to the specified format.
    PARSERS = {
      :json => lambda{|body| MultiJson.decode(body) rescue body },
      :query => lambda{|body| Rack::Utils.parse_query(body) },
      :text => lambda{|body| body}
    }

    # Content type assignments for various potential HTTP content types.
    CONTENT_TYPES = {
      'application/json' => :json,
      'text/javascript' => :json,
      'application/x-www-form-urlencoded' => :query,
      'text/plain' => :text
    }

    # The parsed response body.
    #   Will attempt to parse application/x-www-form-urlencoded and
    #   application/json Content-Type response bodies
    def parsed
      return nil unless PARSERS.key?(parser)
      @parsed ||= PARSERS[parser].call(body)
    end

    # Attempts to determine the content type of the response.
    def content_type
      ((response.headers.values_at('content-type', 'Content-Type').compact.first || '').split(';').first || '').strip
    end

    # Determines the parser that will be used to supply the content of #parsed
    def parser
      return options[:parse].to_sym if PARSERS.key?(options[:parse])
      CONTENT_TYPES[content_type]
    end
  end
end

begin
  require 'multi_xml'
  OAuth2::Response.register_parser(:xml, ['text/xml', 'application/rss+xml', 'application/rdf+xml', 'application/atom+xml']) do |body|
    MultiXml.parse(body) rescue body
  end
rescue LoadError; end
