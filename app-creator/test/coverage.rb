require 'simplecov'
require_relative 'simplecov_json'
require_relative 'runs_text_reporter'
require_relative 'slim_json_reporter'

# The code is at ${APP_DIR}/source and the tests at the sibling ${APP_DIR}/test,
# so SimpleCov's root is ${APP_DIR} to cover both groups (see Dockerfile, ../saver).
APP_DIR = ENV['APP_DIR']

SimpleCov.start do
  enable_coverage(:branch)
  filters.clear
  coverage_dir(ENV['COVERAGE_ROOT'])
  root(APP_DIR)
  # group('debug') { |path| puts(path.filename); false }
  group('code') { |path| path.filename.start_with?("#{APP_DIR}/source/") }
  group('test') { |path| path.filename.start_with?("#{APP_DIR}/test/") }
end

formatters = [SimpleCov::Formatter::HTMLFormatter,
              CoverageMetricsFormatter]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)

Minitest::Reporters.use!([
  RunsTextReporter.new,
  Minitest::Reporters::SlimJsonReporter.new,
  Minitest::Reporters::JUnitReporter.new("#{ENV.fetch('COVERAGE_ROOT')}/junit")
])
