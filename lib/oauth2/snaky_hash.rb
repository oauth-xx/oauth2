# frozen_string_literal: true

module OAuth2
  # Hash which allow assign string key in camel case
  # and query on both camel and snake case
  class SnakyHash < ::Hash
    # Build from another hash or SnakyHash
    #
    # @param [Hash, SnakyHash] hash initial values for hash
    def self.build(hash)
      new.merge!(hash)
    end

    def [](key)
      super(key) || super(camelize(key)) || super(camelize_upcase_first_letter(key))
    end

    def fetch(key, *extras)
      super(key) { nil } || super(camelize(key)) { nil } || super(camelize_upcase_first_letter(key), *extras)
    rescue KeyError
      raise KeyError, "key not found: \"#{key}\""
    end

    def key?(key)
      super(key) || super(camelize(key)) || super(camelize_upcase_first_letter(key))
    end

  private

    def camelize_upcase_first_letter(string)
      string.sub(/^[a-z\d]*/, &:capitalize).
        gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }.
        gsub('/', '::')
    end

    def camelize(string)
      string.sub(/^(?:(?=\b|[A-Z_])|\w)/, &:downcase).
        gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }.
        gsub('/', '::')
    end
  end
end
