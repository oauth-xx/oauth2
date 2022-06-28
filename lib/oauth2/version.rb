# frozen_string_literal: true

module OAuth2
  module Version
    VERSION = to_s

  module_function

    # The major version
    #
    # @return [Integer]
    def major
      1
    end

    # The minor version
    #
    # @return [Integer]
    def minor
      4
    end

    # The patch version
    #
    # @return [Integer]
    def patch
      10
    end

    # The pre-release version, if any
    #
    # @return [String, NilClass]
    def pre
      nil
    end

    # The version number as a hash
    #
    # @return [Hash]
    def to_h
      {
        :major => major,
        :minor => minor,
        :patch => patch,
        :pre => pre,
      }
    end

    # The version number as an array
    #
    # @return [Array]
    def to_a
      [major, minor, patch, pre].compact
    end

    # The version number as a string
    #
    # @return [String]
    def to_s
      v = [major, minor, patch].compact.join('.')
      v += "-#{pre}" if pre
      v
    end
  end
end
