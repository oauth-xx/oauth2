# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.17.3', '< 3.0']
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
  spec.summary       = 'A Ruby wrapper for the OAuth 2.0 protocol.'
  spec.version       = OAuth2::Version.to_s
  spec.post_install_message = %q{
You have installed oauth2 version 1.4.x, which is EOL.
No further support is anticipated for the 1.4.x series.

OAuth2 version 2 is released, and there are BREAKING changes!

Please see:
• https://github.com/oauth-xx/oauth2#what-is-new-for-v20
• https://github.com/oauth-xx/oauth2/blob/master/CHANGELOG.md

Please upgrade, report issues, and support the project! Thanks, |7eter l-|. l3oling

}

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/oauth-xx/oauth2/issues',
    'changelog_uri' => "https://github.com/oauth-xx/oauth2/blob/v#{spec.version}/CHANGELOG.md",
    'documentation_uri' => "https://www.rubydoc.info/gems/oauth2/#{spec.version}",
    'source_code_uri' => "https://github.com/oauth-xx/oauth2/tree/v#{spec.version}",
    'wiki_uri' => 'https://github.com/oauth-xx/oauth2/wiki',
    'funding_uri' => 'https://github.com/sponsors/pboling',
    'rubygems_mfa_required' => 'true',
  }

  spec.require_paths = %w[lib]
  spec.bindir        = 'exe'
  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md', 'CHANGELOG.md', 'CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'SECURITY.md']
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_development_dependency 'addressable', '~> 2.3'
  spec.add_development_dependency 'bundler', '>= 1.16'
  spec.add_development_dependency 'rake', '>= 12.3'
  spec.add_development_dependency 'rexml', '~> 3.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-block_is_expected'
  spec.add_development_dependency 'rspec-pending_for'
  spec.add_development_dependency 'rspec-stubbed_env'
  spec.add_development_dependency 'rubocop-lts', ['>= 2.0.3', '~>2.0']
  spec.add_development_dependency 'silent_stream'
end
