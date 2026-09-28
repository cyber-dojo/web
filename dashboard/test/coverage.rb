require 'simplecov'
require_relative 'simplecov_formatter_json'

APP_DIR = ENV.fetch('APP_DIR')

SimpleCov.start do
  coverage_dir(ENV.fetch('COVERAGE_ROOT'))
  enable_coverage(:branch)
  primary_coverage(:branch)
  filters.clear
  skip('test/id58_test_base.rb')
  root(APP_DIR)

  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME')
  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME')
  # group('debug') { |path| puts(path.filename); false }
  group(code_tab) { |path| path.filename.start_with?("#{APP_DIR}/source/") }
  group(test_tab) { |path| path.filename.start_with?("#{APP_DIR}/test/") }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
