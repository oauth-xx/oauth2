require "bundler/gem_tasks"

defaults = []

# See: https://docs.gitlab.com/ci/variables/predefined_variables/
is_gitlab = ENV.fetch("GITLAB_CI", "false").casecmp("true") == 0

### DEVELOPMENT TASKS
# Setup Kettle Soup Cover
begin
  require "kettle-soup-cover"

  Kettle::Soup::Cover.install_tasks
  # NOTE: Coverage on CI is configured independent of this task.
  #       This task is for local development, as it opens results in browser
  defaults << "coverage" unless Kettle::Soup::Cover::IS_CI
rescue LoadError
  desc("(stub) coverage is unavailable")
  task("coverage") do
    warn("NOTE: kettle-soup-cover isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

# Setup Bundle Audit
begin
  require "bundler/audit/task"

  Bundler::Audit::Task.new
  defaults.push("bundle:audit:update", "bundle:audit")
rescue LoadError
  desc("(stub) bundle:audit is unavailable")
  task("bundle:audit") do
    warn("NOTE: bundler-audit isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
  desc("(stub) bundle:audit:update is unavailable")
  task("bundle:audit:update") do
    warn("NOTE: bundler-audit isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec)
  defaults << "spec"
rescue LoadError
  desc("spec task stub")
  task(:spec) do
    warn("NOTE: rspec isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

desc "run spec task with test task"
task test: :spec

# Setup RuboCop-LTS
begin
  require "rubocop/lts"

  Rubocop::Lts.install_tasks
  # Make autocorrect the default rubocop task
  defaults << "rubocop_gradual:autocorrect"
rescue LoadError
  desc("(stub) rubocop_gradual is unavailable")
  task(:rubocop_gradual) do
    warn("NOTE: rubocop-lts isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

# Setup Yard
begin
  require "yard"

  YARD::Rake::YardocTask.new(:yard) do |t|
    t.files = [
      # Source Splats (alphabetical)
      "lib/**/*.rb",
      "-", # source and extra docs are separated by "-"
      # Extra Files (alphabetical)
      "*.cff",
      "*.md",
      "*.txt",
    ]
  end
  defaults << "yard"
rescue LoadError
  desc("(stub) yard is unavailable")
  task(:yard) do
    warn("NOTE: yard isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

# Setup Reek
begin
  require "reek/rake/task"

  Reek::Rake::Task.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = "{lib,spec}/**/*.rb"
  end
  defaults << "reek" unless is_gitlab
rescue LoadError
  desc("(stub) reek is unavailable")
  task(:reek) do
    warn("NOTE: reek isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

### RELEASE TASKS
# Setup stone_checksums
begin
  require "stone_checksums"

  GemChecksums.install_tasks
rescue LoadError
  desc("(stub) build:generate_checksums is unavailable")
  task("build:generate_checksums") do
    warn("NOTE: stone_checksums isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

task default: defaults
