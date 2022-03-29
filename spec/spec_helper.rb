# frozen_string_literal: true

# Third Party Libraries
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'
require 'addressable/uri'
require 'rspec/pending_for'
require 'rspec/block_is_expected'

# Extensions
require 'ext/backports'

DEBUG = ENV['DEBUG'] == 'true'
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version, engine = 'ruby') { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == engine }
coverage = minimum_version.call('2.7') && RUN_COVERAGE
debug = minimum_version.call('2.5') && DEBUG

if DEBUG
  if debug
    require 'byebug'
  elsif minimum_version.call('2.7', 'jruby')
    require 'pry-debugger-jruby'
  end
end

require 'simplecov' if coverage

# This gem
require 'oauth2'

# Library Configs
require 'config/multi_xml'
require 'config/faraday'

# RSpec Configs
require 'config/rspec/rspec_core'
require 'config/rspec/silent_stream'

VERBS = %i[get post put delete].freeze
