# frozen_string_literal: true

# Third Party Libraries
require 'rspec'
require 'rspec/stubbed_env'
require 'silent_stream'
require 'addressable/uri'
require 'rspec/pending_for'

# Extensions
require 'ext/backports'

DEBUG = ENV['DEBUG'] == 'true'
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == 'ruby' }
coverage = minimum_version.call('2.7') && RUN_COVERAGE
debug = minimum_version.call('2.5') && DEBUG

require 'byebug' if DEBUG && debug
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
