# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.8', '< 2.0']
  spec.add_dependency 'jwt', ['>= 1.0', '< 3.0']
  spec.add_dependency 'multi_json', '~> 1.3'
  spec.add_dependency 'multi_xml', '~> 0.5'
  spec.add_dependency 'rack', ['>= 1.2', '< 3']

  spec.authors       = ['Peter Boling', 'Michael Bleigh', 'Erik Michaels-Ober']
  spec.description   = 'A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec.'
  spec.email         = ['peter.boling@gmail.com']
  spec.homepage      = 'https://github.com/oauth-xx/oauth2'
  spec.licenses      = %w[MIT]
  spec.name          = 'oauth2'
  spec.required_ruby_version = '>= 1.9.0'
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary       = 'A Ruby wrapper for the OAuth 2.0 protocol.'
  spec.version       = OAuth2::Version

  spec.require_paths = %w[lib]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features)/})
  end

  spec.add_development_dependency 'addressable', '~> 2.3'
  spec.add_development_dependency 'backports', '~> 3.11'
  spec.add_development_dependency 'bundler', '>= 1.16'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rdoc', ['>= 5.0', '< 7']
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-stubbed_env'
  spec.add_development_dependency 'rspec-pending_for'
  spec.add_development_dependency 'rspec-block_is_expected'
  spec.add_development_dependency 'silent_stream'
  spec.add_development_dependency 'wwtd'
end
