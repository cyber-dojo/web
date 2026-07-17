# Mobbing false-positive: web-side causes still live after #381

Status: findings, not yet code changes. This catalogs THREE distinct web-side
causes that can still raise the false "mobbing?" dialog for a single browser
driving a kata-id - no second laptop is actually interfering - on the code
that includes #381 (Option A: the `GET /kata/next_index/:id` route, the client
`resyncIndex`, and the inter-test fetch abort raised from 2s to 30s). All three
are in web's code (the browser mismanages its own `index`); the saver's only role
is to correctly reject the resulting bad index. See
`mobbing-server-owned-index-design.md` (Option C) and
`mobbing-laptop-id-design.md` for the surrounding design.

## The report

A trusted instructor running group sessions (many avatars) still gets the false
"mobbing?" dialog on the deployed Option A code. So #381 did not fix the problem
for them. The dialog is false because each affected kata-id is driven by a single
browser mismanaging its own `index`, not by two laptops genuinely interfering on
that kata-id.

## Summary of causes

The dialog fires whenever a `[test]` reaches the saver with an `index` that is
not `committed_head + 1`. That happens two ways: the browser index falls BEHIND
the head, or it runs AHEAD of it.

- Cause 1 - `waitForITE` 2s bail-out. Index falls BEHIND. Fixed by Option C.
- Cause 2 - `run_tests` rescue path fabricates `index + 1` on a non-out-of-order
  saver error. Index runs AHEAD. NOT fixed by Option C (an ahead index is still
  rejected), and the uncommitted working tree leaves this path unchanged.
- Cause 3 - a lost/aborted `[test]` response the saver still committed. Index
  falls BEHIND. Fixed by Option C; NOT fixed by #381 (Option A only resynced
  inter-test events, never the `[test]` path).

Cause 2 is the one that needs a web fix regardless of Option C.

## Cause 1 - the second 2-second timeout (`waitForITE`)

#381 raised ONE 2-second timeout (the inter-test `fetch` abort, now 30s) but
left a SECOND, independent 2-second timeout untouched, and that second one is the
live trigger.

The `[test]` button is not fired directly. `_test_button.erb:11` gates it behind
an in-progress inter-test event:

```js
$button.click(() => cd.waitForITE(() => kata.testButton.click()));
```

`cd.waitForITE` (`_file_inter_test_events.erb`) polls `_interTestEventInProgress`
but abandons the wait after `maxWait = 2000` ms and runs the callback regardless:

```js
const pollInterval = 50;
const maxWait = 2000;
let elapsed = 0;
const poll = setInterval(() => {
  elapsed += pollInterval;
  if (!_interTestEventInProgress || elapsed >= maxWait) {
    clearInterval(poll);
    callback();
  }
}, pollInterval);
```

Mechanism:

1. During normal editing of a kata an inter-test file event fires (selecting a file
   `_filenames.erb:130`, clicking a traffic light `_traffic_lights.erb:42`, a
   file create/delete/rename `_file_create_rename_delete.erb`, download, etc).
   It sets `_interTestEventInProgress = true` and POSTs at the current
   `kata.index`, advancing the index ONLY when its response arrives via
   `kata.setIndex(newIndex)`.
2. #381 lets that event run for up to 30s (its own abort is now 30s). If it
   takes longer than 2s and the user clicks `[test]`, `waitForITE` gives up at
   2000ms and fires the test while the event is still in flight, so `kata.index`
   is still stale (behind the head).
3. The saver commits the inter-test event (the committed head advances). The
   `[test]` POST arrives carrying the stale index. On the deployed (Option A)
   saver a stale index is rejected as an out-of-order event, the
   `/kata/run_tests` handler maps that to `out_of_sync: true`, and
   `_run_tests.erb`'s `out_of_sync` branch calls `cd.mobbingPoll.check()`, which
   locks the tab (the "mobbing?" modal for another laptop, the app-bar message
   for another tab).

So raising the fetch abort from 2s to 30s actually WIDENED the window:
inter-test events are now allowed to run up to 30s, but `waitForITE` still
abandons its wait at 2s and lets `[test]` race ahead with a stale index. Same
2-second root cause, a different timer that #381 did not touch. This is the
"slow-[test]-retry case Option A never closed" referred to in
`mobbing-server-owned-index-design.md` (the KEY FRAMING paragraph).

Fixed by Option C: the `[test]` carries the SAME laptop's `laptop_id`, so the
events in the stale `index .. head` range are all the user's own in-flight write.
The saver classifies this as self-lag, accepts it, and shows no dialog. The
in-process-git compare-and-swap serializes the two concurrent same-laptop writes
and places both correctly.

## Cause 2 - `run_tests` rescue path advances the index on a non-out-of-order saver error

`app.rb` `post '/kata/run_tests/:id'` (deployed and unchanged in the working
tree):

```ruby
rescue SaverService::Error => error
  next_index  = index + 1          # fabricated even though NOTHING committed
  major_index = index + 1
  minor_index = ''
  @saved = false
  $stdout.puts(error.message)
  $stdout.flush
  @out_of_sync = error.message.include?('Out of order event')
end
```

If the saver save raises ANY `SaverService::Error` whose message is not
`'Out of order event'` (the saver restarting or overloaded, a connection reset, a
500), then `@out_of_sync` is false and the response carries `out_of_sync: false`
with a fabricated `next_index = index + 1`. In `_run_tests.erb`, `handleResponse`
takes the `else` branch and calls `refreshFromTest`, which does:

```js
cd.kata.setIndex(light.index + 1);   // light.index == next_index - 1 == index
```

so the browser advances to `index + 1`. But nothing was committed - the head is
unchanged. The browser index is now ONE AHEAD of the head. The very next
`[test]` sends an ahead index, which the saver rejects as out-of-order, and the
browser shows the false dialog.

This is a two-step failure: a transient saver hiccup silently ARMS the desync,
and the next `[test]` FIRES the dialog. A browser refresh clears it
(`edit.erb` resets `index` to `events.length`), so it presents as an
intermittent false dialog with no obvious trigger.

NOT fixed by Option C. Under Option C the saver places a write at `head + 1` and
still rejects an index that is AHEAD of that (`raise when index > head + 1`), so
the ahead index from this path is still rejected. The uncommitted working tree
leaves this rescue block unchanged (it adds `laptop_id` and switches `revert()`
to `setIndex`, but does not touch the fabricated `+1`). The fix is web-side and
independent: do not advance the browser index when the save did not commit (eg
do not `setIndex` when `@saved == false`, or stop fabricating `next_index` on the
rescue path and signal the client not to advance).

## Cause 3 - a lost or aborted `[test]` response the saver still committed

`_run_tests.erb` `runTests` aborts the `[test]` POST after 30s and, on any
fetch failure, shows a generic error dialog without touching the index:

```js
const timer = setTimeout(() => controller.abort(), 30000);
...
.then(handleResponse)
.catch(err => cd.dialogError(err.message))   // generic dialog; no setIndex, no resync
.finally(() => { clearTimeout(timer); cd.waitSpinner.fadeOut('slow', onComplete); });
```

If the `[test]` POST is lost client-side (the 30s abort on a slow runner-plus-save,
or a network drop) but the saver commits, the head advances while the browser
index stays put (behind the head). The next `[test]` sends the stale index and
the saver rejects it as out-of-order - the false dialog. Like cause 2 this is a
two-step failure: the lost response shows only a generic error, and the NEXT
`[test]` shows "mobbing?".

This is exactly the lost-response problem #381 fixed for INTER-TEST events - but
the fix (`resyncIndex`) was only wired into `syncPostWithCallbackITE`. The
`[test]`/`run_tests` path never got a resync, so it was never covered.

Fixed by Option C: the stale `[test]` carries the same `laptop_id`, the
`index .. head` range is all the user's own committed `ran_tests` event, so the
saver self-lag-accepts it and a refresh re-syncs. NOT fixed by #381.

(A 429 from nginx rate-limiting does NOT cause this: a 429 is rejected before it
reaches the saver, so nothing commits, the head does not move, and the index
stays correct. The `[test]` fetch just shows a generic error dialog.)

## Decision this drives

- Deploying the saver (Option C Phases 1+2) plus web sending `laptop_id` closes
  causes 1 and 3 (both "behind head", both become self-lag accepts). Nothing in
  these findings is a reason to delay that saver deploy; saver-first is the
  design's required order and is what unblocks the fix.
- Cause 2 must be fixed in web regardless, because an ahead index is still
  rejected under Option C. This fix is small and local to the `run_tests` rescue
  path and `refreshFromTest`.
- Cause 1's `waitForITE` 2s cap: if Option C is imminent, patching it is
  throwaway work (Option C makes it benign and Phase 3 does not touch it). If
  Option C is NOT imminent, align the two timeouts via a single shared constant
  (eg `INTER_TEST_TIMEOUT_MS = 30000`) used for both the fetch abort and
  `waitForITE`'s `maxWait`, removing the class of bug (two coupled timeouts that
  drifted apart) rather than just this instance. The `finally` block already
  clears `_interTestEventInProgress` on every outcome, so `waitForITE` unblocks
  with a correct index IF it waits long enough.

## Note for the Option C plan

`mobbing-server-owned-index-design.md` (Phases 3-4) never mentions `waitForITE`
or its 2s `maxWait`. That is fine for correctness under Option C (cause 1 becomes
benign), but the coupled-timeout smell (a 2s gate guarding a 30s operation)
survives into the Option C end-state as dead-but-confusing code. Worth a one-line
note there that the cap is intentionally left as a harmless UI debounce, so a
future reader does not rediscover it as a "bug". The plan should also add cause 2
as an explicit web fix, since Option C does not cover it.

## Code map

- `source/app/app.rb` - `post '/kata/run_tests/:id'`: the rescue block that
  fabricates `next_index = index + 1` (cause 2) and maps the out-of-order error
  to `out_of_sync:`; `get '/kata/next_index/:id'` is the Option A route.
- `source/app/views/kata/_run_tests.erb` - `runTests` `.catch` with no resync
  (cause 3); `refreshFromTest` does `setIndex(light.index + 1)` (cause 2); reads
  `out_of_sync` and calls `cd.mobbingPoll.check()` to lock the tab.
- `source/app/views/kata/_file_inter_test_events.erb` - `cd.waitForITE`
  (`maxWait = 2000`, cause 1) and `syncPostWithCallbackITE` (30s fetch abort,
  sets and clears `_interTestEventInProgress`).
- `source/app/views/kata/_test_button.erb:11` - `[test]` gated behind
  `cd.waitForITE` (cause 1).
- `source/app/services/saver_service.rb` - `kata_ran_tests` (and the other 8
  write methods) carry `laptop_id` in the uncommitted Option C work.
