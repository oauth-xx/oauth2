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

require 'simplecov' if coverage
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
