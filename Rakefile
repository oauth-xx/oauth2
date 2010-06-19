require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "oauth2"
    gem.summary = %Q{A Ruby wrapper for the OAuth 2.0 protocol.}
    gem.description = %Q{A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth gem.}
    gem.email = "michael@intridea.com"
    gem.homepage = "http://github.com/intridea/oauth2"
    gem.authors = ["Michael Bleigh"]
    gem.add_dependency 'faraday', '~> 0.4.1'
    gem.add_dependency 'multi_json', '>= 0.0.4'
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new

  task :spec => :check_dependencies
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end

  task :default => :spec
rescue LoadError
  puts "RSpec (or a dependency) not available. Install it with: gem install rspec"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "oauth2 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
