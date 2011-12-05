require 'simplecov'
SimpleCov.start
require 'oauth2'
require 'rspec'
require 'rspec/autorun'

Faraday.default_adapter = :test

RSpec.configure do |conf|
  include OAuth2
end
