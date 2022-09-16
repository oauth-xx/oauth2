# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.17.3', '< 3.0']
  spec.add_dependency 'jwt', ['>= 1.0', '< 3.0']
  spec.add_dependency 'multi_json', '~> 1.3'
  spec.add_dependency 'multi_xml', '~> 0.5'
  spec.add_dependency 'rack', ['>= 1.2', '< 4']

  spec.authors       = ['Peter Boling', 'Erik Michaels-Ober', 'Michael Bleigh']
  spec.description   = 'A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec.'
  spec.email         = ['peter.boling@gmail.com']
  spec.homepage      = 'https://gitlab.com/oauth-xx/oauth2'
  spec.licenses      = %w[MIT]
  spec.name          = 'oauth2'
  spec.required_ruby_version = '>= 1.9.0'
  spec.summary       = 'A Ruby wrapper for the OAuth 2.0 protocol.'
  spec.version       = OAuth2::Version.to_s
  spec.post_install_message = "
You have installed oauth2 version #{OAuth2::Version}, which is EOL.
No further support is anticipated for the 1.4.x series.

OAuth2 version 2 is released.
There are BREAKING changes, but most will not encounter them, and upgrading should be easy!

We have made two other major migrations:
1. master branch renamed to main
2. Github has been replaced with Gitlab

Please see:
• https://gitlab.com/oauth-xx/oauth2#what-is-new-for-v20
• https://gitlab.com/oauth-xx/oauth2/-/blob/main/CHANGELOG.md
• https://groups.google.com/g/oauth-ruby/c/QA_dtrXWXaE

Please upgrade, report issues, and support the project! Thanks, |7eter l-|. l3oling

"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/-/tree/v#{spec.version}"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/-/issues"
  spec.metadata['documentation_uri'] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['wiki_uri'] = "#{spec.homepage}/-/wiki"
  spec.metadata['funding_uri'] = 'https://liberapay.com/pboling'
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
  spec.add_development_dependency 'bundler', '>= 1.16'
  spec.add_development_dependency 'rake', '>= 12'
  spec.add_development_dependency 'rexml', '>= 3'
  spec.add_development_dependency 'rspec', '>= 3'
  spec.add_development_dependency 'rspec-block_is_expected'
  spec.add_development_dependency 'rspec-pending_for'
  spec.add_development_dependency 'rspec-stubbed_env'
  spec.add_development_dependency 'rubocop-lts', ['>= 2.0.3', '~>2.0']
  spec.add_development_dependency 'silent_stream'
end
