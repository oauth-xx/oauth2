# frozen_string_literal: true

# HOW TO UPDATE APPRAISALS:
#   BUNDLE_GEMFILE=Appraisal.root.gemfile bundle
#   BUNDLE_GEMFILE=Appraisal.root.gemfile bundle exec appraisal update

# Used for head (nightly) releases of ruby, truffleruby, and jruby.
# Split into discrete appraisals if one of them needs a dependency locked discretely.
appraise "head" do
  gem "mutex_m", ">= 0.2"
  gem "stringio", ">= 3.0"
  eval_gemfile "modular/runtime_heads.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Test current Rubies against head versions of runtime dependencies
appraise "current-runtime-heads" do
  gem "mutex_m", ">= 0.2"
  gem "stringio", ">= 3.0"
  eval_gemfile "modular/runtime_heads.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Used for current releases of ruby, truffleruby, and jruby.
# Split into discrete appraisals if one of them needs a dependency locked discretely.
appraise "current" do
  gem "mutex_m", ">= 0.2"
  gem "stringio", ">= 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v3.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-3" do
  eval_gemfile "modular/faraday_v0.gemfile"
  eval_gemfile "modular/jwt_v1.gemfile"
  eval_gemfile "modular/logger_v1_2.gemfile"
  eval_gemfile "modular/multi_xml_v0_5.gemfile"
  eval_gemfile "modular/rack_v1_2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-4" do
  eval_gemfile "modular/faraday_v1.gemfile"
  eval_gemfile "modular/jwt_v1.gemfile"
  eval_gemfile "modular/logger_v1_2.gemfile"
  eval_gemfile "modular/multi_xml_v0_5.gemfile"
  eval_gemfile "modular/rack_v1_6.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-5" do
  eval_gemfile "modular/faraday_v1.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_5.gemfile"
  eval_gemfile "modular/multi_xml_v0_6.gemfile"
  eval_gemfile "modular/rack_v2.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-6" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_5.gemfile"
  eval_gemfile "modular/multi_xml_v0_6.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-2-7" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_6.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-0" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_6.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-1" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_6.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-2" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "ruby-3-3" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run security audit on latest Ruby version
appraise "audit" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/audit.gemfile"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run coverage on latest Ruby version
appraise "coverage" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/coverage.gemfile"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

# Only run linter on latest Ruby version (but, in support of oldest supported Ruby version)
appraise "style" do
  gem "mutex_m", "~> 0.2"
  gem "stringio", "~> 3.0"
  eval_gemfile "modular/style.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "omnibus" do
  eval_gemfile "modular/audit.gemfile"
  eval_gemfile "modular/coverage.gemfile"
  eval_gemfile "modular/documentation.gemfile"
  eval_gemfile "modular/faraday_v2.gemfile"
  eval_gemfile "modular/jwt_v2.gemfile"
  eval_gemfile "modular/logger_v1_7.gemfile"
  eval_gemfile "modular/multi_xml_v0_7.gemfile"
  eval_gemfile "modular/rack_v3.gemfile"
  eval_gemfile "modular/style.gemfile"
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end

appraise "vanilla" do
  remove_gem "appraisal" # only present because it must be in the gemfile because we target a git branch
end
