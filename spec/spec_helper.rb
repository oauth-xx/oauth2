$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'oauth2'
require 'spec'
require 'spec/autorun'

OAuth2::Client.default_connection_adapter = :test

Spec::Runner.configure do |config|
  
end
