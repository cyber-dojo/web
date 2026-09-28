require 'json'
require 'minitest/reporters'

# Writes the run's headline numbers as json, so the limits in
# test/server/config/ are checked against data rather than parsed prose.
class Minitest::Reporters::SlimJsonReporter < Minitest::Reporters::BaseReporter
  # Writes test_metrics.json beside the coverage report.
  def report
    super
    filename = "#{ENV.fetch('COVERAGE_ROOT')}/test_metrics.json"
    metrics = {
      total_time: total_time.round(2),
      assertion_count: assertions,
      test_count: count,
      failure_count: failures,
      error_count: errors,
      skip_count: skips
    }
    File.write(filename, JSON.pretty_generate(metrics))
  end
end
