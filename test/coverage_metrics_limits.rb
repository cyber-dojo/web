
# The gate's limits, read by check_metrics.rb against coverage_metrics.json.
# A missed count uses == where the metric is already at zero and must stay
# there, and <= where it is a ratchet: the number may fall, never rise.
# A total uses <= so that growing the code or the suite is a deliberate act,
# noticed here and acknowledged by raising the limit.
def metrics
  [
    [ nil ],
    [ 'test.lines.total'    , '<=', 1340 ],
    [ 'test.lines.missed'   , '<=',    9 ],
    [ 'test.branches.total' , '<=',   26 ],
    [ 'test.branches.missed', '<=',    8 ],
    [ nil ],
    [ 'code.lines.total'    , '<=',  496 ],
    [ 'code.lines.missed'   , '==',    0 ],
    [ 'code.branches.total' , '<=',   33 ],
    [ 'code.branches.missed', '<=',    3 ]
  ]
end
