# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby_version = Gem::Version.new(RUBY_VERSION)

# No need to run byebug / pry on earlier versions
debuggable_version = Gem::Version.new('2.4')

### deps for documentation and rdoc.info
group :documentation do
  gem 'github-markup', platform: :mri
  gem 'rdoc'
  gem 'redcarpet', platform: :mri
  gem 'yard', require: false
end

group :development, :test do
  if ruby_version >= debuggable_version
    gem 'byebug', platform: :mri
    gem 'pry', platform: :mri
    gem 'pry-byebug', platform: :mri
  end

  if ruby_version >= Gem::Version.new('2.7')
    # No need to run rubocop or simplecov on earlier versions
    gem 'rubocop', '~> 1.9', platform: :mri
    gem 'rubocop-md', platform: :mri
    gem 'rubocop-packaging', platform: :mri
    gem 'rubocop-performance', platform: :mri
    gem 'rubocop-rake', platform: :mri
    gem 'rubocop-rspec', platform: :mri

    gem 'coveralls', platform: :mri
    gem 'simplecov', platform: :mri
  end
end
