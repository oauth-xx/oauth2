require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec

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
  # we only need to do style check once
  require 'rubocop/rake_task'
  if Kernel.const_defined?(:RUBY_ENGINE) && Kernel.const_get(:RUBY_ENGINE) == 'ruby'
    RuboCop::RakeTask.new
  else
    task :rubocop do
      $stdout.puts 'Rubocop is disable for this platform'
    end
  end
rescue LoadError
  task :rubocop do
    $stderr.puts 'RuboCop is disabled'
  end
end

require 'yardstick/rake/measurement'
Yardstick::Rake::Measurement.new do |measurement|
  measurement.output = 'measurement/report.txt'
end

require 'yardstick/rake/verify'
Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 58.8
end

task :default => [:spec, :rubocop, :verify_measurements]
