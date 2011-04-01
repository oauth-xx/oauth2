begin
  require 'bundler/setup'
rescue LoadError
  puts 'although not required, it is recommended that you use bundler during development'
end

require 'oauth2'
require 'rspec'
require 'rspec/autorun'

Faraday.default_adapter = :test
