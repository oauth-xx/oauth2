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

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version, engine = 'ruby') { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == engine }
actual_version = lambda do |major, minor|
  actual = Gem::Version.new(ruby_version)
  major == actual.segments[0] && minor == actual.segments[1] && RUBY_ENGINE == 'ruby'
end
debugging = minimum_version.call('2.7') && DEBUG
RUN_COVERAGE = minimum_version.call('2.6') && (ENV['COVER_ALL'] || ENV['CI_CODECOV'] || ENV['CI'].nil?)
ALL_FORMATTERS = actual_version.call(2, 7) && (ENV['COVER_ALL'] || ENV['CI_CODECOV'] || ENV['CI'])

if DEBUG
  if debugging
    require 'byebug'
  elsif minimum_version.call('2.7', 'jruby')
    require 'pry-debugger-jruby'
  end
end

require 'simplecov' if RUN_COVERAGE

# This gem
require 'oauth2'

# Library Configs
require 'config/multi_xml'
require 'config/faraday'

# RSpec Configs
require 'config/rspec/rspec_core'
require 'config/rspec/silent_stream'

VERBS = %i[get post put delete].freeze
