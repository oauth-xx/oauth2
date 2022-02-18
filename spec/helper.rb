DEBUG = ENV['DEBUG'] == 'true'
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7') && RUN_COVERAGE
debug = minimum_version.call('2.5') && DEBUG

require 'simplecov' if coverage
require 'byebug' if debug

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
