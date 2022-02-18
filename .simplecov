SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch

  if ENV['CI'] || ENV['CODECOV']
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
