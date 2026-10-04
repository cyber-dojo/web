
def metrics
  [
    [ nil ],
    [ 'code.lines.total'    , '<=', 533 ],
    [ 'code.lines.missed'   , '==',   0 ],
    [ 'code.branches.total' , '<=',  54 ],
    [ 'code.branches.missed', '==',   0 ],
    [ nil ],
    [ 'test.lines.total'    , '<=', 747 ],
    [ 'test.lines.missed'   , '==',   0 ],
    [ 'test.branches.total' , '==',   0 ],
    [ 'test.branches.missed', '==',   0 ],
  ]
end
