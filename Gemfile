source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  if ruby_version >= Gem::Version.new('2.1')
    gem 'rubocop', '~> 0.52.1'
    gem 'rubocop-rspec', '~> 1.22.1'
  end
  gem 'pry', '~> 0.11' if ruby_version >= Gem::Version.new('2.0')
end

# Specify non-special dependencies in oauth2.gemspec
gemspec
