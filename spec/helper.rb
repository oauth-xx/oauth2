DEBUG = ENV['DEBUG'] == 'true'

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7')
debug = minimum_version.call('2.5')

require 'simplecov' if coverage
require 'byebug' if DEBUG && debug

require 'oauth2'
require 'addressable/uri'
require 'rspec'
require 'rspec/stubbed_env'
require 'rspec/pending_for'
require 'silent_stream'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Faraday.default_adapter = :test

RSpec.configure do |conf|
  conf.include SilentStream
end

VERBS = [:get, :post, :put, :delete].freeze
