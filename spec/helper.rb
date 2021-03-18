# frozen_string_literal: true

require 'oauth2'
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'

ruby_version = Gem::Version.new(RUBY_VERSION)

# No need to get coverage for older versions of Ruby
coverable_version = Gem::Version.new('2.7')

if ruby_version >= coverable_version
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    Coveralls::SimpleCov::Formatter,
                                                                  ])

  SimpleCov.start do
    add_filter '/spec'
    minimum_coverage(95)
  end
end

require 'addressable/uri'

Faraday.default_adapter = :test

DEBUG = ENV['DEBUG'] == 'true'
require 'byebug' if DEBUG && RUBY_VERSION >= '2.6'

# This is dangerous - HERE BE DRAGONS.
# It allows us to refer to classes without the namespace, but at what cost?!?
# TODO: Refactor to use explicit references everywhere
include OAuth2

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SilentStream
end

VERBS = %i[get post put delete].freeze
