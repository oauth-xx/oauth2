# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'faraday', ['>= 0.8', '< 2.0'], :platforms => [:jruby_18, :ruby_18]
gem 'jwt', '< 1.5.2', :platforms => [:jruby_18, :ruby_18]
gem 'rake', '< 11.0'

ruby_version = Gem::Version.new(RUBY_VERSION)

### deps for documentation and rdoc.info
group :documentation do
  gem 'github-markup', :platform => :mri
  gem 'rdoc'
  gem 'redcarpet', :platform => :mri
  gem 'yard', :require => false
end

group :development, :test do
  if ruby_version >= Gem::Version.new('2.4')
    # No need to run byebug / pry on earlier versions
    gem 'byebug', :platform => :mri
    gem 'pry', :platform => :mri
    gem 'pry-byebug', :platform => :mri
  end

  if ruby_version >= Gem::Version.new('2.7')
    # No need to run rubocop or simplecov on earlier versions
    gem 'rubocop', '~> 1.9', :platform => :mri
    gem 'rubocop-md', :platform => :mri
    gem 'rubocop-packaging', :platform => :mri
    gem 'rubocop-performance', :platform => :mri
    gem 'rubocop-rake', :platform => :mri
    gem 'rubocop-rspec', :platform => :mri

    gem 'coveralls'
    gem 'simplecov', :platform => :mri
  end
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
