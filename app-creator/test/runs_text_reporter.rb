require 'minitest/reporters'

# Prints the detail of any failures/errors (the base StatisticsReporter only
# tallies them, so otherwise a failure shows only as a count and its detail
# lives solely in the JUnit XML), then prints the summary in 'runs' terminology
# so cyberdojo/check-test-metrics can parse the 'Finished in Xs, Y runs/s' and
# 'N runs, N assertions...' lines.
class RunsTextReporter < Minitest::Reporters::BaseReporter
  # Prints failure detail then the 'runs' summary.
  def report
    super
    print_failures
    io.printf("Finished in %.6fs, %.4f runs/s, %.4f assertions/s.\n\n",
              total_time, count / total_time, assertions / total_time)
    io.puts "#{count} runs, #{assertions} assertions, " \
            "#{failures} failures, #{errors} errors, #{skips} skips"
  end

  private

  # Writes each failed/errored test's label, identity, message and (filtered)
  # backtrace to stdout so failures are debuggable without opening the JUnit XML.
  # An empty message is called out as "no failure message" rather than printed
  # as a confusing blank line.
  def print_failures
    tests.each do |result|
      next if result.passed? || result.skipped?

      result.failures.each do |failure|
        message = failure.message.to_s.strip
        io.puts
        io.puts "#{failure.result_label}: #{result.klass}##{result.name}"
        io.puts message.empty? ? 'no failure message' : message
        Minitest.filter_backtrace(failure.backtrace).each { |line| io.puts "  #{line}" }
      end
    end
  end
end
