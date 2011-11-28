# encoding: utf-8
require File.expand_path('../lib/oauth2/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'faraday', '~> 0.7'
  gem.add_dependency 'multi_json', '~> 1.0'
  gem.add_development_dependency 'multi_xml'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.authors = ["Michael Bleigh", "Erik Michaels-Ober"]
  gem.description = %q{A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth gem.}
  gem.email = ['michael@intridea.com', 'sferik@gmail.com']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/intridea/oauth2'
  gem.name = 'oauth2'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  gem.summary = %q{A Ruby wrapper for the OAuth 2.0 protocol.}
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = OAuth2::VERSION
end
