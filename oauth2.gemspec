# encoding: utf-8
# frozen_string_literal: true

require_relative 'lib/oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.17.3', '< 3.0']
  spec.add_dependency 'jwt', ['>= 1.0', '< 3.0']
  spec.add_dependency 'multi_xml', '~> 0.5'
  spec.add_dependency 'rack', ['>= 1.2', '< 4']
  spec.add_dependency 'snaky_hash', '~> 2.0'
  spec.add_dependency 'version_gem', '~> 1.1'

  spec.cert_chain  = ['certs/pboling.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  spec.authors = ['Peter Boling', 'Erik Michaels-Ober', 'Michael Bleigh']
  spec.summary = 'OAuth 2.0 Core Ruby implementation'
  spec.description = 'A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec.'
  spec.email = ['peter.boling@gmail.com', 'oauth-ruby@googlegroups.com']
  spec.homepage = 'https://gitlab.com/oauth-xx/oauth2'
  spec.licenses = 'MIT'
  spec.name = 'oauth2'
  spec.required_ruby_version = '>= 2.2.0'
  spec.version = OAuth2::Version::VERSION
  spec.post_install_message = "
You have installed oauth2 version #{OAuth2::Version::VERSION}, congratulations!

There are BREAKING changes if you are upgrading from < v2, but most will not encounter them, and updating your code should be easy!
Please see:
• #{spec.homepage}/-/blob/main/SECURITY.md
• #{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md#2010-2022-09-19
• Summary: #{spec.homepage}#what-is-new-for-v20

Major updates:
1. master branch renamed to main
• Update your local: git checkout master; git branch -m master main; git branch --unset-upstream; git branch -u origin/main
2. Github has been replaced with Gitlab; I wrote about some of the reasons here:
• https://dev.to/galtzo/im-leaving-github-50ba
• Update your local: git remote set-url origin git@gitlab.com:oauth-xx/oauth2.git
3. Google Group is active (again)!
• https://groups.google.com/g/oauth-ruby/c/QA_dtrXWXaE
4. Gitter Chat is active (still)!
• https://gitter.im/oauth-xx/
5. Non-commercial support for the 2.x series will end by April, 2024. Please make a plan to upgrade to the next version prior to that date.
Support will be dropped for Ruby 2.2, 2.3, 2.4, 2.5, 2.6, 2.7 and any other Ruby versions which will also have reached EOL by then.
6. Gem releases are now cryptographically signed for security.

If you are a human, please consider a donation as I move toward supporting myself with Open Source work:
• https://liberapay.com/pboling
• https://ko-fi.com/pboling
• https://patreon.com/galtzo

If you are a corporation, please consider supporting this project, and open source work generally, with a TideLift subscription.
• https://tidelift.com/funding/github/rubygems/oauth
• Or hire me. I am looking for a job!

Please report issues, and support the project!

Thanks, |7eter l-|. l3oling
"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/-/tree/v#{spec.version}"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/-/issues"
  spec.metadata['documentation_uri'] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['wiki_uri'] = "#{spec.homepage}/-/wiki"
  spec.metadata['mailing_list_uri'] = 'https://groups.google.com/g/oauth-ruby'
  spec.metadata['funding_uri'] = 'https://liberapay.com/pboling'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.require_paths = %w[lib]
  spec.files = Dir[
    'lib/**/*',
    'CHANGELOG.md',
    'CODE_OF_CONDUCT.md',
    'CONTRIBUTING.md',
    'LICENSE.txt',
    'README.md',
    'SECURITY.md',
  ]

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
