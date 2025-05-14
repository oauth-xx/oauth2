# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }
git_source(:gitlab) { |repo_name| "https://gitlab.com/#{repo_name}" }

#### IMPORTANT #######################################################
# Gemfile is for local development ONLY; Gemfile is NOT loaded in CI #
####################################################### IMPORTANT ####

# Include dependencies from <gem name>.gemspec
gemspec

platform :mri do
  # Use binding.break, binding.b, or debugger in code
  gem "debug", ">= 1.0.0"                  # ruby >= 2.7
  gem "gem_bench", "~> 2.0", ">= 2.0.5"
end

# Security Audit
eval_gemfile "gemfiles/modular/audit.gemfile"

# Code Coverage
eval_gemfile "gemfiles/modular/coverage.gemfile"

# Linting
eval_gemfile "gemfiles/modular/style.gemfile"

# Documentation
eval_gemfile "gemfiles/modular/documentation.gemfile"

gem "appraisal", github: "pboling/appraisal", branch: "galtzo"
