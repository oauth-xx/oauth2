# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

platforms :mri do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == "ruby" }
  linting = minimum_version.call("2.7")
  coverage = minimum_version.call("2.7")
  debug = minimum_version.call("2.5")
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
    gem "simplecov"
    gem "simplecov-cobertura"
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
  gem 'github-markup', platform: :mri
  gem 'rdoc'
  gem 'redcarpet', platform: :mri
  gem 'yard', require: false
end
