source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'faraday', '~> 0.15.2', :platforms => [:jruby_18, :ruby_18]
gem 'jwt', '< 1.5.2', :platforms => [:jruby_18, :ruby_18]

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  if ruby_version >= Gem::Version.new('2.1')
    # TODO: Upgrade to >= 0.59 when we drop Rubies below 2.2
    #     Error: Unsupported Ruby version 2.1 found in `TargetRubyVersion` parameter (in .rubocop.yml). 2.1-compatible analysis was dropped after version 0.58.
    #     Supported versions: 2.2, 2.3, 2.4, 2.5
    gem 'rubocop', '~> 0.68.0'
    gem 'rubocop-rspec', '~> 1.32.0' # last version that can use rubocop < 0.58
  end
  gem 'coveralls'
  gem 'pry', '~> 0.11' if ruby_version >= Gem::Version.new('2.0')
  gem 'rspec-pending_for'
  gem 'simplecov', '>= 0.9'
end

# Specify non-special dependencies in oauth2.gemspec
gemspec
