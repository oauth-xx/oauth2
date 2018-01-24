# encoding: utf-8

# !/usr/bin/env rake

require 'bundler/gem_tasks'

# rubocop:disable Lint/HandleExceptions
begin
  require 'wwtd/tasks'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :test => :spec
rescue LoadError
  # puts "failed to load wwtd or rspec, probably because bundled --without-development"
end
# rubocop:enable Lint/HandleExceptions

namespace :doc do
  require 'rdoc/task'
  require File.expand_path('../lib/oauth2/version', __FILE__)
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "oauth2 #{OAuth2::Version}"
    rdoc.main = 'README.md'
    rdoc.rdoc_files.include('README.md', 'LICENSE.md', 'lib/**/*.rb')
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    warn 'RuboCop is disabled'
  end
end

task :default => [:spec, :rubocop]
