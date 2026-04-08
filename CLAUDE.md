
When you press the [test] button in cyber-dojo this creates saves the information for
that submission in the saver service whose source code is in the ../saver repo.
Each [test] submission also creates a new traffic-light in the top app-bar.
If you hover on the traffic-light it shows you a small summary of the diff between
that traffic-light and the previous traffic-light. This diff-summary is created using
the differ service whose source code is in the ../differ repo.

For example, if I edit only readme.txt and press [test] then I get a hover-tip
telling me that only readme.txt has been edited.

If I then edit a different file, eg hiker.py (suppose I am doing an TDD exercise using the
python-pytest language-test-framwork) and readme.txt and press [test] then I get
a hover-tip telling me that those two files were edited.

However, if I then edit __only_ hiker.py and press [test] the hover-tip tells me that
hiker.py and readme.txt have been edited.

What is the cause of this bug.

## Root cause and fix

The bug is in `source/app/views/kata/_traffic_lights.html.erb`.

The kata page tracks the previous traffic-light's index in a variable called
`previousIndex`, which is passed as the `was_index` when setting up each
hover-tip diff. After appending each traffic-light it updates `previousIndex`:

```javascript
previousIndex = light.major_index;  // was wrong
```

`light.major_index` is the **count** of traffic lights so far (1, 2, 3, …).
For v2 katas, `file_edit` events are inserted into the events array between
tests, so the count diverges from the actual event-array index. For example:

| Event            | Event index | major_index |
|------------------|-------------|-------------|
| create           | 0           | 0           |
| file_edit        | 1           | —           |
| ran-tests 1      | 2           | 1           |
| file_edit        | 3           | —           |
| ran-tests 2      | 4           | 2           |
| file_edit        | 5           | —           |
| ran-tests 3      | 6           | 3           |

After test 2, `previousIndex` is set to `major_index = 2`, which is the
event-array index of **test 1**, not test 2. So the hover diff for test 3
is computed between test 1 and test 3, showing files changed in test 2
(e.g. readme.txt) as if they were also changed in test 3.

The fix is to use `light.index` (the actual event-array position) instead:

```javascript
previousIndex = light.index;  // fixed
```

Note: the review page (`source/app/views/review/_index.html.erb`) was
already correct — it computes `previousIndex` from `events[index].minor_index`
via `polyfill_major_minor_events`, which gives the right answer.

