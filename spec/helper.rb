if RUBY_VERSION >= '1.9'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter]

  SimpleCov.start do
    add_filter '/spec'
    minimum_coverage(95.33)
  end
end

require 'oauth2'
require 'addressable/uri'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Faraday.default_adapter = :test

RSpec.configure do |conf|
  include OAuth2
end

def capture_output
  begin
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    result = $stdout.string
  ensure
    $stdout = old_stdout
  end
  result
end

VERBS = [:get, :post, :put, :delete].freeze
