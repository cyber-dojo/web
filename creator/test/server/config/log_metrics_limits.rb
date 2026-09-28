
# The run's output must be clean. A second entry, eg service_log_warnings for a
# container's start-up log, belongs here rather than in another mechanism.
def metrics
  [
    [ nil ],
    [ 'test_log_warnings', '==', 0 ],
  ]
end
