# frozen_string_literal: true

require 'oauth2'
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'

DEBUG = ENV['DEBUG'] == 'true'
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7') && RUN_COVERAGE
debug = minimum_version.call('2.5') && DEBUG

require 'simplecov' if coverage
require 'byebug' if debug

require 'addressable/uri'

Faraday.default_adapter = :test

require 'byebug' if DEBUG && debug

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SilentStream
end

VERBS = %i[get post put delete].freeze
