# encoding: utf-8
# frozen_string_literal: true

require_relative 'lib/oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.17.3', '< 3.0']
  spec.add_dependency 'jwt', ['>= 1.0', '< 3.0']
  spec.add_dependency 'multi_xml', '~> 0.5'
  spec.add_dependency 'rack', ['>= 1.2', '< 3']
  spec.add_dependency 'rash_alt', ['>= 0.4', '< 1']

  spec.authors       = ['Peter Boling', 'Michael Bleigh', 'Erik Michaels-Ober']
  spec.description   = 'A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec.'
  spec.email         = ['peter.boling@gmail.com']
  spec.homepage      = 'https://github.com/oauth-xx/oauth2'
  spec.licenses      = %w[MIT]
  spec.name          = 'oauth2'
  spec.required_ruby_version = '>= 2.2.0'
  spec.required_rubygems_version = '>= 2.7.11'
  spec.summary       = 'A Ruby wrapper for the OAuth 2.0 protocol.'
  spec.version       = OAuth2::Version.to_s

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['wiki_uri'] = "#{spec.homepage}/wiki"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.require_paths = %w[lib]
  spec.bindir        = 'exe'
  spec.files = Dir[
    'lib/**/*',
    'CHANGELOG.md',
    'CODE_OF_CONDUCT.md',
    'CONTRIBUTING.md',
    'LICENSE',
    'README.md',
    'SECURITY.md',
  ]
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_development_dependency 'addressable', '>= 2'
  spec.add_development_dependency 'backports', '>= 3'
  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'rake', '>= 12'
  spec.add_development_dependency 'rexml', '>= 3'
  spec.add_development_dependency 'rspec', '>= 3'
  spec.add_development_dependency 'rspec-block_is_expected'
  spec.add_development_dependency 'rspec-pending_for'
  spec.add_development_dependency 'rspec-stubbed_env'
  spec.add_development_dependency 'rubocop-lts', '~> 8.0'
  spec.add_development_dependency 'silent_stream'
end
