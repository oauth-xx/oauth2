source 'https://rubygems.org'

gem 'faraday', '~> 0.9.2', :platforms => [:jruby_18, :ruby_18]
gem 'jwt', '< 1.5.2', :platforms => [:jruby_18, :ruby_18]
gem 'rake', '< 11.0'
gem 'rdoc', '~> 4.2.2'

group :development do
  gem 'pry'
end

group :test do
  gem 'addressable', '~> 2.3.8'
  gem 'backports'
  gem 'coveralls'
  gem 'rack', '~> 1.2', :platforms => [:jruby_18, :jruby_19, :ruby_18, :ruby_19, :ruby_20, :ruby_21]
  gem 'rspec', '>= 3'
  gem 'rubocop', '>= 0.37', :platforms => [:ruby_20, :ruby_21, :ruby_22, :ruby_23]
  gem 'simplecov', '>= 0.9'
  gem 'yardstick'

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

gemspec
