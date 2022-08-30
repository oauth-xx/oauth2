# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }
git_source(:gitlab) { |repo_name| "https://gitlab.com/#{repo_name}" }

gem 'rake', '~> 13.0'

gem 'rspec', '~> 3.0'

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version, engine = 'ruby') { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == engine }
linting = minimum_version.call('2.7')
coverage = minimum_version.call('2.7')
debug = minimum_version.call('2.5')

gem 'overcommit', '~> 0.58' if linting

platforms :mri do
  if linting
    # Danger is incompatible with Faraday 2 (for now)
    # see: https://github.com/danger/danger/issues/1349
    # gem 'danger', '~> 8.4'
    gem 'rubocop-md', require: false
    # Can be added once we reach rubocop-lts >= v10 (i.e. drop Ruby 2.2)
    # gem 'rubocop-packaging', require: false
    gem 'rubocop-performance', require: false
    gem 'rubocop-rake', require: false
    gem 'rubocop-rspec', require: false
    gem 'rubocop-thread_safety', require: false
  end
  if coverage
    gem 'codecov', '~> 0.6' # For CodeCov
    gem 'simplecov', '~> 0.21', require: false
    gem 'simplecov-cobertura' # XML for Jenkins
    gem 'simplecov-json' # For CodeClimate
    gem 'simplecov-lcov', '~> 0.8', require: false
  end
  if debug
    # Add `byebug` to your code where you want to drop to REPL
    gem 'byebug'
  end
end
platforms :jruby do
  # Add `binding.pry` to your code where you want to drop to REPL
  gem 'pry-debugger-jruby'
end

### deps for documentation and rdoc.info
group :documentation do
  gem 'github-markup', platform: :mri
  gem 'redcarpet', platform: :mri
  gem 'yard', require: false
end
