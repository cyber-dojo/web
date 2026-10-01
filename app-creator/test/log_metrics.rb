require 'json'

# Writes log_metrics.json: the numbers that only the run's output can answer,
# rather than anything reporting them. Run by test/run.sh once the log is
# complete, so check_metrics.rb can gate on it like any other data file.
#
# ': warning:' is what cyberdojo/check-test-metrics scanned for, so the same
# warnings are counted as before it was replaced. A ruby -W2 warning from the
# suite, or from anything it loads, lands in the log and is caught here.

log_filename = ARGV[0]
out_filename = ARGV[1]

metrics = {
  'test_log_warnings' => File.read(log_filename).scan(/: warning:/m).size
}

File.write(out_filename, JSON.pretty_generate(metrics))
