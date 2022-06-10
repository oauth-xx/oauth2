# frozen_string_literal: true

module OAuth2
  module Version
    VERSION = '2.0.0.rc1'.freeze

  module_function

    # The version number as a string
    #
    # @return [String]
    def to_s
      VERSION
    end

    # The major version
    #
    # @return [Integer]
    def major
      to_a[0].to_i
    end

    # The minor version
    #
    # @return [Integer]
    def minor
      to_a[1].to_i
    end

    # The patch version
    #
    # @return [Integer]
    def patch
      to_a[2].to_i
    end

    # The pre-release version, if any
    #
    # @return [String, NilClass]
    def pre
      to_a[3]
    end

    # The version number as a hash
    #
    # @return [Hash]
    def to_h
      {
        major: major,
        minor: minor,
        patch: patch,
        pre: pre,
      }
    end

    # The version number as an array
    #
    # @return [Array]
    def to_a
      VERSION.split('.')
    end
  end
end
