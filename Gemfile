# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'jwt'
gem 'overcommit'
gem 'rake'

group :test do
  gem 'addressable', '~> 2.3.8'
  gem 'backports'
  gem 'rack', '~> 1.2', :platforms => [:ruby_21]
  gem 'rspec', '>= 3'
  platforms :mri do
    ruby_version = Gem::Version.new(RUBY_VERSION)
    minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
    linting = minimum_version.call('2.7')
    coverage = minimum_version.call('2.7')
    debug = minimum_version.call('2.5')
    if linting
      # Danger is incompatible with Faraday 2 (for now)
      # see: https://github.com/danger/danger/issues/1349
      # gem 'danger', '~> 8.4'
      gem 'rubocop', '~> 1.22', :require => false
      gem 'rubocop-md', '~> 1.0', :require => false
      gem 'rubocop-packaging', '~> 0.5', :require => false
      gem 'rubocop-performance', '~> 1.11', :require => false
      gem 'rubocop-rake', '~> 0.6', :require => false
      gem 'rubocop-rspec', :require => false
      gem 'rubocop-thread_safety', '~> 0.4', :require => false
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
