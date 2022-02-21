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
      fetch(key)
    rescue KeyError
      nil
    end

    def fetch(key, *extras)
      super(key) do |_|
        super(camelize_upcase_first_letter(key)) do |_|
          if extras.any?
            super(camelize(key), *extras)
          else
            super(camelize(key))
          end
        end
      end
    end

    def key?(key)
      fetch(key)
      true
    rescue KeyError
      false
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
