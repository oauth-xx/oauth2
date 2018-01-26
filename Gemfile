source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  gem 'rubocop', '~> 0.52.1' if ruby_version >= Gem::Version.new('2.1')
end

# Specify non-special dependencies in oauth2.gemspec
gemspec
