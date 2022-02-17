# frozen_string_literal: true

require 'oauth2'
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'

DEBUG = ENV['DEBUG'] == 'true'

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7')
debug = minimum_version.call('2.5')

if coverage
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

require 'byebug' if DEBUG && debug

require 'addressable/uri'

Faraday.default_adapter = :test

DEBUG = ENV['DEBUG'] == 'true'
require 'byebug' if DEBUG && debug

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SilentStream
end

VERBS = %i[get post put delete].freeze
