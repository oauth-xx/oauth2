# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'faraday', ['>= 0.8', '< 2.0'], :platforms => [:jruby_18, :ruby_18]
gem 'jwt', '< 1.5.2', :platforms => [:jruby_18, :ruby_18]
gem 'rake', '< 11.0'
gem "overcommit"

platforms :mri do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == "ruby" }
  linting = minimum_version.call("2.7")
  coverage = minimum_version.call("2.7")
  debug = minimum_version.call("2.4")
  if linting
    gem "danger", "~> 8.4"
    gem "rubocop", "~> 1.22"
    gem "rubocop-md", "~> 1.0"
    gem "rubocop-packaging", "~> 0.5"
    gem "rubocop-performance", "~> 1.11"
    gem "rubocop-rake", "~> 0.6"
    gem "rubocop-rspec"
    gem "rubocop-thread_safety", "~> 0.4"
  end
  if coverage
    gem 'coveralls'
    gem "simplecov", "~> 0.21"
    gem "simplecov-cobertura", "~> 2.1"
  end
  if debug
    # No need to run byebug / pry on earlier versions
    gem 'byebug'
    gem 'pry'
    gem 'pry-byebug'
  end
end

### deps for documentation and rdoc.info
group :documentation do
  gem 'github-markup', :platform => :mri
  gem 'rdoc'
  gem 'redcarpet', :platform => :mri
  gem 'yard', :require => false
end

group :test do
  gem 'addressable', '~> 2.3.8'
  gem 'backports'
  gem 'rack', '~> 1.2', :platforms => [:jruby_18, :jruby_19, :ruby_18, :ruby_19, :ruby_20, :ruby_21]
  gem 'rspec', '>= 3'

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
