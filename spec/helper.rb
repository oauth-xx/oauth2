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

  SimpleCov.start do
    if ENV['CI']
      require 'simplecov-lcov'
      require 'simplecov-cobertura'
      require 'coveralls'

      SimpleCov::Formatter::LcovFormatter.config do |c|
        c.report_with_single_file = true
        c.single_report_path = 'coverage/lcov.info'
      end

      SimpleCov.formatters = [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::LcovFormatter,
        SimpleCov::Formatter::CoberturaFormatter,
        Coveralls::SimpleCov::Formatter,
      ]
    else
      formatter SimpleCov::Formatter::HTMLFormatter
    end

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
