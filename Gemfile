source 'https://rubygems.org'

gem 'rake'
gem 'rdoc'

group :development do
  gem 'pry'
end

group :test do
  gem 'addressable', '< 2.4.0' # 2.4.0 does not support ruby 1.8.7
  gem 'backports'
  gem 'coveralls'
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rest-client', '~> 1.6.0', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '>= 3'
  gem 'rubocop', '>= 0.25', :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'simplecov', '>= 0.9'
  gem 'yardstick'
end

gemspec
