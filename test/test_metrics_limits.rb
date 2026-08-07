
# The gate's limits, read by check_metrics.rb against test_metrics.json.
# test_count has a floor rather than a ceiling: it catches tests disappearing,
# which a suite that still passes would otherwise hide.
# total_time is wall-clock for the whole suite in one process, running its test
# classes in parallel, which sits under 15s and varies by a second between runs.
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=', 118 ],
    [ 'total_time',    '<=',  30 ],
    [ nil ],
    [ 'failure_count', '==',   0 ],
    [ 'error_count',   '==',   0 ],
    [ 'skip_count',    '==',   0 ]
  ]
end
