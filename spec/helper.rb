DEBUG = ENV['DEBUG'] == 'true'

ruby_version = Gem::Version.new(RUBY_VERSION)

if ruby_version >= Gem::Version.new('2.7')
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter]

  SimpleCov.start do
    add_filter '/spec'
    minimum_coverage(95)
  end
end

require 'byebug' if DEBUG && ruby_version >= Gem::Version.new('2.4')

require 'oauth2'
require 'addressable/uri'
require 'rspec'
require 'rspec/stubbed_env'
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
