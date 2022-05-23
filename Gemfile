# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'overcommit'

group :test do
  gem 'addressable', '>= 2.3'
  gem 'rspec', '>= 3'
  platforms :mri do
    ruby_version = Gem::Version.new(RUBY_VERSION)
    minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
    linting = minimum_version.call('2.7')
    coverage = minimum_version.call('2.7')
    debug = minimum_version.call('2.5')
    if linting
      gem 'rubocop-rspec', '1.5.0', :require => false
      gem 'rubocop-thread_safety', '0.3.1', :require => false
    end
    if coverage
      gem 'codecov', :require => false, :group => :test
      gem 'simplecov', '~> 0.21', :require => false
      gem 'simplecov-cobertura' # XML for Jenkins
      gem 'simplecov-lcov', '~> 0.8', :require => false
    end
    if debug
      # No need to run byebug / pry on earlier versions
      gem 'byebug'
      gem 'pry'
      gem 'pry-byebug'
    end
  end
end

### deps for documentation and rdoc.info
group :documentation do
  gem 'github-markup', :platform => :mri
  gem 'redcarpet', :platform => :mri
  gem 'yard', :require => false
end
