
def metrics
  [
    [ nil ],
    [ 'test_count',    '>=',  80 ],
    [ 'total_time',    '<=',  20 ],
    [ nil ],
    [ 'failure_count', '==',   0 ],
    [ 'error_count'  , '==',   0 ],
    [ 'skip_count'   , '==',   0 ],
  ]
end
