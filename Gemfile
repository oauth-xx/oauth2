source 'https://rubygems.org'

gem 'rake'
gem 'rdoc'

group :development do
  gem 'pry'
  platforms :ruby_19, :ruby_20 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'addressable'
  gem 'backports'
  gem 'coveralls', :require => false
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rubocop', '>= 0.19', :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'rspec', '>= 2.14'
  gem 'simplecov', :require => false
  gem 'yardstick'
end

gemspec
