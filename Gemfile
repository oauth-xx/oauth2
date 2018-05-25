source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  if ruby_version >= Gem::Version.new('2.1')
    gem 'rubocop', '~> 0.56.0'
    gem 'rubocop-rspec', '~> 1.25.1'
  end
  gem 'pry', '~> 0.11' if ruby_version >= Gem::Version.new('2.0')
  gem 'rspec-pending_for'
end

# Specify non-special dependencies in oauth2.gemspec
gemspec
