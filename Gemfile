source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'faraday', '~> 0.9.2', :platforms => [:jruby_18, :ruby_18]
gem 'jwt', '< 1.5.2', :platforms => [:jruby_18, :ruby_18]
gem 'rake', '< 11.0'
gem 'rdoc', '~> 4.2.2'

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  if ruby_version >= Gem::Version.new('2.1')
    # TODO: Upgrade to >= 0.59 when we drop Rubies below 2.2
    #     Error: Unsupported Ruby version 2.1 found in `TargetRubyVersion` parameter (in .rubocop.yml). 2.1-compatible analysis was dropped after version 0.58.
    #     Supported versions: 2.2, 2.3, 2.4, 2.5
    gem 'rubocop', '~> 0.57.0'
    gem 'rubocop-rspec', '~> 1.27.0' # last version that can use rubocop < 0.58
  end
  gem 'pry', '~> 0.11' if ruby_version >= Gem::Version.new('2.0')
  gem 'rspec-pending_for'

  gem 'addressable', '~> 2.3.8'
  gem 'backports'
  gem 'coveralls'
  gem 'rack', '~> 1.2', :platforms => [:jruby_18, :jruby_19, :ruby_18, :ruby_19, :ruby_20, :ruby_21]
  gem 'rspec', '>= 3'
  gem 'simplecov', '>= 0.9'

  platforms :jruby_18, :ruby_18 do
    gem 'mime-types', '~> 1.25'
    gem 'rest-client', '~> 1.6.0'
  end

  platforms :ruby_18, :ruby_19 do
    gem 'json', '< 2.0'
    gem 'term-ansicolor', '< 1.4.0'
    gem 'tins', '< 1.7'
  end
end

gemspec
