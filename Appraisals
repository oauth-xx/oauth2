# For a list of available precompiled Rubies on Travis, see http://rubies.travis-ci.org/

# TODO: Ruby < 2.2 will not be supported in oauth2 versions >= 2.x
appraise 'ruby-1.8' do
  gem 'faraday', '~> 0.9.2'
  gem 'jwt', '< 1.5.2'
  gem 'mime-types', '~> 1.25'
  gem 'rest-client', '~> 1.6.0'
  gem 'rack', '~> 1.2'
end

appraise 'jruby-1.7' do
  gem 'faraday', '~> 0.9.2'
  gem 'jwt', '< 1.5.2'
  gem 'mime-types', '~> 1.25'
  gem 'rest-client', '~> 1.6.0'
  gem 'rack', '~> 1.2'
end

appraise 'ruby-1.9' do
  gem 'json', '< 2.0'
  gem 'term-ansicolor', '< 1.4.0'
  gem 'tins', '< 1.7'
  gem 'rack', '~> 1.2'
end

appraise 'ruby-2.0' do
  gem 'rack', '~> 1.2'
end

appraise 'ruby-2.1' do
  gem 'rack', '~> 1.2'
end

appraise 'jruby-9.0' do
  gem 'rack', '~> 1.2'
end

# DEPRECATION WARNING
# oauth2 1.x series releases are the last to support Ruby versions above
# oauth2 2.x series releases will support Ruby versions below, and not above

appraise 'jruby-9.1' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'ruby-2.2' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'ruby-2.3' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'ruby-2.4' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'ruby-2.5' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'jruby-head' do
  gem 'rubocop', '~> 0.52.1'
end

appraise 'ruby-head' do
  gem 'rubocop', '~> 0.52.1'
end
