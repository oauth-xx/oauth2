unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end
require 'oauth2'
require 'addressable/uri'
require 'rspec'
require 'rspec/autorun'

Faraday.default_adapter = :test

RSpec.configure do |conf|
  include OAuth2
end
