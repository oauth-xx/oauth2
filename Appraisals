# frozen_string_literal: true

# HOW TO UPDATE APPRAISALS:
#   BUNDLE_GEMFILE=Appraisal.root.gemfile bundle
#   BUNDLE_GEMFILE=Appraisal.root.gemfile bundle exec appraisal update

# Used for head (nightly) releases of ruby, truffleruby, and jruby.
# Split into discrete appraisals if one of them needs a dependency locked discretely.
appraise "head" do
  gem "mutex_m", ">= 0.2"
  gem "stringio", ">= 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Used for current releases of ruby, truffleruby, and jruby.
# Split into discrete appraisals if one of them needs a dependency locked discretely.
appraise "current" do
  gem "mutex_m", ">= 0.2"
  gem "stringio", ">= 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-2" do
  eval_gemfile "modular/f0.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-3" do
  eval_gemfile "modular/f0.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-4" do
  eval_gemfile "modular/f1.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-5" do
  eval_gemfile "modular/f1.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-6" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-7" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-0" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-1" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-2" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-3" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run security audit on latest Ruby version
appraise "audit" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  eval_gemfile "modular/audit.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run coverage on latest Ruby version
appraise "coverage" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  eval_gemfile "modular/coverage.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run linter on latest Ruby version (but, in support of oldest supported Ruby version)
appraise "style" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/f2.gemfile"
  eval_gemfile "modular/style.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "omnibus" do
  eval_gemfile "modular/audit.gemfile"
  eval_gemfile "modular/coverage.gemfile"
  eval_gemfile "modular/documentation.gemfile"
  eval_gemfile "modular/f2.gemfile"
  eval_gemfile "modular/style.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "vanilla" do
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end
