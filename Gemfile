source 'https://rubygems.org'

gem 'rake'
gem 'rdoc'

group :test do
  gem 'addressable'
  gem 'coveralls', :require => false
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '>= 2.14'
  gem 'simplecov', :require => false
end

platforms :rbx do
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl', '~> 2.0'
end

gemspec
