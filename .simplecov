# frozen_string_literal: true

# To get coverage
# On Local, default (HTML) output, it just works, coverage is turned on:
#   bundle exec rspec spec
# On Local, all output formats:
#   COVER_ALL=true bundle exec rspec spec
#
# On CI, all output formats, the ENV variables CI is always set,
#   and COVER_ALL, and CI_CODECOV, are set in the coverage.yml workflow only,
#   so coverage only runs in that workflow, and outputs all formats.
#
if RUN_COVERAGE
  SimpleCov.start do
    enable_coverage :branch
    primary_coverage :branch

    if ENV['COVER_ALL']
      require 'codecov'
      require 'simplecov-lcov'
      require 'simplecov-cobertura'

      SimpleCov::Formatter::LcovFormatter.config do |c|
        c.report_with_single_file = true
        c.single_report_path = 'coverage/lcov.info'
      end

      SimpleCov.formatters = [
        SimpleCov::Formatter::CoberturaFormatter,
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::LcovFormatter,
        SimpleCov::Formatter::Codecov,
      ]
    else
      formatter SimpleCov::Formatter::HTMLFormatter
    end

    add_filter '/spec'
    minimum_coverage(85)
  end
end
