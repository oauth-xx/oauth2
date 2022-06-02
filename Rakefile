# encoding: utf-8
# frozen_string_literal: true

# !/usr/bin/env rake

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'spec task stub'
  task :spec do
    warn 'rspec is disabled'
  end
end
desc 'alias test task to spec'
task test: :spec

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.options = ['-D'] # Display the name of the failing cops
  end
rescue LoadError
  desc 'rubocop task stub'
  task :rubocop do
    warn 'RuboCop is disabled'
  end
end

# namespace :doc do
#   require 'rdoc/task'
#   require 'oauth2/version'
#   RDoc::Task.new do |rdoc|
#     rdoc.rdoc_dir = 'rdoc'
#     rdoc.title = "oauth2 #{OAuth2::Version}"
#     rdoc.main = 'README.md'
#     rdoc.rdoc_files.include('README.md', 'LICENSE.md', 'lib/**/*.rb')
#   end
# end

task default: %i[test rubocop]
