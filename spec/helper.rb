# frozen_string_literal: true

# Third Party Libraries
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'
require 'addressable/uri'

DEBUG = ENV['DEBUG'] == 'true'
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7') && RUN_COVERAGE
debug = minimum_version.call('2.5') && DEBUG

require 'simplecov' if coverage
require 'byebug' if DEBUG && debug

# This gem
require 'oauth2'

Faraday.default_adapter = :test

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SilentStream
end

VERBS = %i[get post put delete].freeze
