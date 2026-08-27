require 'simplecov'
require_relative 'simplecov_formatter_json'
require_relative 'slim_json_reporter'
require_relative 'slow_tests_reporter'

# The image copies source/server/ to ${APP_DIR}/source, so production code sits
# at ${APP_DIR}/source and the tests at the sibling ${APP_DIR}/test. Rooting
# SimpleCov at ${APP_DIR} covers both groups (see Dockerfile).
APP_DIR = ENV.fetch('APP_DIR')

SimpleCov.start do

  root(APP_DIR)
  # where coverage reports are written
  coverage_dir(ENV.fetch('COVERAGE_ROOT'))
  # Branch coverage as well as line coverage, so the attested metrics say
  # whether both sides of a condition were taken, not merely that the line ran.
  enable_coverage(:branch)
  # Silence 'failed to recognize the test framework' warning
  command_name('Unit Tests')

  # Groups are selected by directory, so a new production file joins the code
  # group the moment it is added. These two names are the keys of the
  # coverage_metrics.json that gets attested, so they are deliberately terse.
  filters.clear
  group('code') { |path| path.filename.start_with?("#{APP_DIR}/source/") }
  group('test') { |path| path.filename.start_with?("#{APP_DIR}/test/") }

  # SimpleCov reports only the files something loaded, so a production file no
  # test reaches would be silently absent rather than reported as uncovered.
  # Tracking them explicitly makes such a file show up at 0% and fail the gate.
  # config/ holds the server boot files (config.ru, puma.rb), which no unit
  # test loads and which are not unit-testable, so they stay untracked.
  # cover does two jobs: it restricts the report to what it names, and for a
  # string glob it also sweeps those off disk so a file nothing loaded still
  # appears, at 0%. Both are relative to root, so an absolute glob matches
  # nothing.
  #
  # source/ wants both jobs, which is the string glob. test/ wants only the
  # restriction: sweeping it would pull in the browser and client tests this
  # run never loads and report them as missed. Only string globs drive the
  # sweep, so the regexp includes the tests that did load and nothing else.
  cover('source/web/**/*.rb', %r{\Atest/})
end

# HTML to read, JSON for the gate and the attestation to consume.
formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)

# The reporters live here, rather than in test_base.rb, because this file is
# loaded only by the run that measures coverage: run.sh names it, and all.rb
# requires it only when COVERAGE_ROOT is set. The browser run loads neither, so
# it needs no conditional to skip them - and a conditional would be a branch
# that no coverage-measuring run could ever take both sides of.
Minitest::Reporters.use!([
  Minitest::Reporters::DefaultReporter.new,
  Minitest::Reporters::SlimJsonReporter.new,
  Minitest::Reporters::JUnitReporter.new("#{ENV.fetch('COVERAGE_ROOT')}/junit"),
  Minitest::Reporters::SlowTestsReporter.new
])

#- - - - - - - - - - - - - - - - - - - - - - -
#group('debug') { |path| puts "coverage:#{path.filename}"; false }
