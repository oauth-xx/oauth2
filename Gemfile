source 'https://rubygems.org'

# RUBY_ENGINE is not defined on ruby 1.8.7
ruby_engine = if defined? RUBY_ENGINE
                RUBY_ENGINE
              else
                'ruby'
              end

ruby_version = Gem::Version.new(RUBY_VERSION)

# For old ruby, restrict these gems to old version
if ruby_version < Gem::Version.new('1.9')
  gem 'faraday', '~> 0.9.2'
  gem 'jwt', '< 1.5.2'
end

gem 'rake', '< 11.0'
gem 'rdoc', '~> 4.2.2'

group :development do
  gem 'pry'
end

group :test do
  gem 'addressable', '~> 2.3.8'
  gem 'backports'
  gem 'coveralls'
  gem 'rspec', '>= 3'
  gem 'simplecov', '>= 0.9'

  # For old ruby, restrict these gems to old version
  if ruby_version < Gem::Version.new('1.9')
    gem 'mime-types', '~> 1.25'
    gem 'rest-client', '~> 1.6.0'
  end
  if ruby_engine == 'ruby' && ruby_version < Gem::Version.new('2.0')
    gem 'json', '< 2.0'
    gem 'term-ansicolor', '< 1.4.0'
    gem 'tins', '< 1.7'
  end
  gem 'rack', '~> 1.2' if ruby_version < Gem::Version.new('2.2')

  # Rubocop only works on new ruby
  gem 'rubocop', '~> 0.52.1' if ruby_version >= Gem::Version.new('2.1')
end

gemspec
