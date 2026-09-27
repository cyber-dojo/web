require 'minitest/reporters'

# Prints the slowest tests once the run has finished.
#
# Durations come from minitest itself (Minitest::Result#time), so nothing here
# re-measures what the harness already timed. Each finished test is pushed onto
# a Thread::Queue, which is thread-safe by construction - that is why this needs
# no mutex, even though the test classes run in parallel.
class Minitest::Reporters::SlowTestsReporter < Minitest::Reporters::BaseReporter

  HOW_MANY = 5

  def initialize(options = {})
    super
    @recorded = Thread::Queue.new
  end

  # Called as each test finishes, from whichever thread ran it.
  def record(result)
    super
    @recorded << [ named(result), result.time ]
  end

  # Called once, after every test has finished, so nothing is still writing to
  # the queue and draining it cannot race with a record.
  def report
    super
    slowest = drained.sort_by { |_named, secs| -secs }.first(HOW_MANY)
    return if slowest.empty?
    puts
    puts "Slowest #{slowest.size} tests are..."
    slowest.each { |named, secs| puts(format('%3.4f - %s', secs, named)) }
  end

  private

  # Everything recorded, as [name, seconds] pairs. Draining empties the queue.
  def drained
    all = []
    all << @recorded.pop until @recorded.empty?
    all
  end

  # How one test is named in the report. A test's method name is generated from
  # its id and its multi-line description, so the whitespace is collapsed to
  # keep each report line to one line.
  def named(result)
    "#{result.klass}##{result.name}".gsub(/\s+/, ' ').strip
  end

end
