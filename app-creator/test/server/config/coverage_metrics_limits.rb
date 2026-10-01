
def metrics
  [
    [ nil ],
    [ 'code.lines.total'    , '<=', 531 ],
    [ 'code.lines.missed'   , '==',   0 ],
    [ 'code.branches.total' , '<=',  52 ],
    [ 'code.branches.missed', '==',   0 ],
    [ nil ],
    [ 'test.lines.total'    , '<=', 677 ],
    [ 'test.lines.missed'   , '==',   0 ],
    [ 'test.branches.total' , '==',   0 ],
    [ 'test.branches.missed', '==',   0 ],
  ]
end
