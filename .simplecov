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
RUN_COVERAGE = ENV['CI_CODECOV'] || ENV['CI'].nil?
if RUN_COVERAGE
  SimpleCov.start do
    enable_coverage :branch
    primary_coverage :branch

    if ENV['COVER_ALL']
      require 'simplecov-lcov'
      require 'simplecov-cobertura'
      require 'coveralls'

      SimpleCov::Formatter::LcovFormatter.config do |c|
        c.report_with_single_file = true
        c.single_report_path = 'coverage/lcov.info'
      end

      SimpleCov.formatters = [
        SimpleCov::Formatter::CoberturaFormatter,
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::LcovFormatter,
        Coveralls::SimpleCov::Formatter,
      ]
    else
      formatter SimpleCov::Formatter::HTMLFormatter
    end

    add_filter '/spec'
    minimum_coverage(86)
  end
end
