# Mobbing false-positive: the concurrent-write cause and the agreed fix

Status: implemented and tested, uncommitted, not deployed. WEB: Phase 3, the cause-2
fix, `laptop_id` forwarding, and the `runTests` re-entry guard (the write-during-test
resolution - step 2 below). SAVER: Phase 1+2 and the directional CAS-loss retry in
`commit_event`. All three rescue directions are covered: DccG02 (different-laptop
reject), DccG03 (same-laptop test retry), DccG04 (same-laptop file-edit drop). Only the
retry-exhaustion sub-branch is uncovered (cannot be forced deterministically).

Related docs (all in web `docs/`):
- `mobbing-server-owned-index-design.md` - Option C (server-owned index +
  per-laptop id + self-lag detection). Its concurrency bullet now documents the
  CAS-loss gap described here.
- `mobbing-web-index-desync-causes.md` - the three web-side causes (1 waitForITE 2s
  bail, 2 run_tests rescue advances index, 3 lost [test] response).
- `mobbing-waitforite-2s-gate-finding.md`, `mobbing-laptop-id-design.md`.

Related memories:
- `saver-cas-loss-no-retry` - the CAS-loss rescue rejects any concurrent loser with
  no laptop_id check and no retry (the design doc's claimed retry does NOT exist).
- `saver-write-methods-index-advance`, `saver-service-laptop-id-required-arg`.

## The exact trigger

The "mobbing?" dialog fires ONLY when a `POST /kata/run_tests` makes the saver raise
`"Out of order event"` (that is the sole source of `out_of_sync: true`, mapped in
`app.rb` and rendered by `_run_tests.erb`'s `showAvatarsOutOfSync`). So every false
dialog is a solo `[test]` reaching the saver with a rejectable index. Under Option C
there are exactly two ways to be rejected: index AHEAD of `head + 1`, or index BEHIND
with a foreign/absent `laptop_id` in the `index .. head` range.

## What is already closed or decided

- AHEAD (`index > head + 1`): closed by Phase 3 + the cause-2 fix. Every browser
  index update is now `setIndex(committed_index + 1)` (page load, run_tests,
  revert, checkout, inter-test); `incrementIndex` is gone; the cause-2 fix stops
  advancing the index when a save did not commit. A committed index is always
  `<= head`, so `index <= head + 1` always. Nothing can push it ahead. (Holds only
  once the WEB Phase 3 + cause-2 changes are deployed; old web still has
  `incrementIndex` and the cause-2 bug.)
- BEHIND, writes SEQUENTIAL: fixed by self-lag in the saver's `commit_on_main`
  block (Phase 2). Requires web forwarding `laptop_id` AND the saver deployed.
- Cause 2 (run_tests rescue fabricated `index + 1` on a non-committing save):
  FIXED in the web working tree - `app.rb` now returns `saved:`, and
  `refreshFromTest` only advances the index when `saved`. Locked by
  `run_tests_save_error_test.rb`.
- Cause 3 (lost `[test]` response): closed by self-lag; covered by
  `mobbing_self_lag_after_lost_event_test.rb` (its second write is a `[test]` at a
  stale index that self-lag-accepts).

## The remaining live cause: concurrent same-laptop CAS loss

The saver's `laptop_id` self-lag verdict runs ONLY in the sequential path (inside
`git.commit_on_main`). The CONCURRENT path (two writes to one kata racing the git
`update-ref` compare-and-swap) is resolved by `commit_event`'s method-level
`rescue`, which re-reads the tip and, if it advanced to `>= index`, raises
`"Out of order event"` - with NO `laptop_id` check and NO retry.

So two CONCURRENT writes from the SAME browser both build on the same base, both pass
the sequential check (both see an empty range at `head + 1`), then race the CAS; the
loser hits the `rescue` and is rejected. If the loser is the `[test]`, that is the
false dialog.

Reachability (verified): web puma has no `threads` directive (default multi-threaded,
so it forwards the two same-browser fetches concurrently); the saver runs
`workers Etc.nprocessors` (10 worker processes observed). The saver's own
`config/puma.rb` comment documents this exact behaviour: two concurrent writes to one
kata, one wins the CAS, "the other fails and is detected as an 'Out of order event'
error, which the web layer treats as an out-of-sync condition and shows a dialog."

Main generator: `waitForITE`'s 2s bail (cause 1) fires `[test]` while an inter-test
event is still in flight, so the two race. In a busy group session (loaded saver,
slower ITEs, more 2s bails, more concurrency) this is very plausibly the instructor's
dominant ongoing trigger. It is not limited to `waitForITE`: any two concurrent
same-laptop writes to one kata hit it.

## Alternatives considered and rejected

- Blind saver retry (retry whichever writer loses the CAS): REJECTED. If the `[test]`
  wins and the older ITE loses, retrying the ITE appends it AFTER the test, storing
  `(ITE, test)` in REVERSE chronological order - and the test event already contains
  the ITE's file change, so the ITE is re-recorded after the test that superseded it.
  Corrupts the log's meaning.
- Disable / wait (block `[test]` while an ITE is in flight): REJECTED. Re-enabling
  only on the ITE's completion means a slow or hung saver blocks test-running (and
  file edits) for up to the 30s ITE abort. That violates the invariant "you must be
  able to run tests and edit files even if the saver is completely broken." (A
  down/refused saver fails fast; a hung or slow-under-load saver does not - and
  slow-under-load is exactly the instructor's condition.) The old 2s bail existed to
  avoid this block, at the cost of the race.
- Web `[test]` re-submit (re-POST run_tests on a self-lag "Out of order"): REJECTED as
  primary. It re-runs the RUNNER (Docker compile+test) on a raced `[test]`, adding
  load precisely under the slow saver that triggers the race.
- Drop `waitForITE` from the `[test]` button (`_test_button.erb`): REJECTED. It looks
  redundant once the retry handles the race, but `waitForITE` is load-bearing for
  STRUCTURAL ops. create/delete/rename send their ITE POST first (filename as a POST
  arg) and mutate the browser editor file-set only in the ITE's `.finally` callback,
  i.e. AFTER the POST (coupled to the saver: `file_create` expects the file NOT yet in
  `files`). So the browser file-SET lags the ITE. If `[test]` fired during an in-flight
  create/rename, its form would miss the structural change and could undo it.
  `waitForITE` waits for that callback to apply before the next save. (file_edit is the
  opposite - its content is copied into the form before the POST - so only the
  structural ops need the guard.) We keep `waitForITE`; the retry handles the residual
  2s-bail race.

## The chosen fix: type-discriminated directional saver retry + web write-during-test gate

Key insight: the reverse-order problem only occurs when the OLDER write is retried.
Retrying the NEWER write (the `[test]`, appended after an earlier ITE) yields CORRECT
order. And the saver can tell them apart WITHOUT a new API argument, by the write TYPE
already in `summary` (a rag colour for a test vs `file_edit`/`file_create`/... for an
ITE). The existing `index` cannot discriminate concurrent losers - two in-flight
writes carry the same `index` (neither has returned) - so type, not index, is the
discriminator. Also note: a saver-internal retry re-attempts only the git commit
(rebuild on the new head + re-CAS), NOT the runner, so there is NO double-run.

SAVER side (`source/server/model/kata_v2.rb`, `commit_event` CAS-loss `rescue`):
- Loser is a `[test]` (rag `summary`) and the racing events are the SAME `laptop_id`:
  retry - rebuild on the new head and re-CAS, appending at `head + 1` (correct order).
  Bounded retries; if exhausted, raise (rare).
- Loser is a `[test]` and a DIFFERENT `laptop_id` is in the range: raise "Out of order"
  (genuine mobbing - the real dialog).
- Loser is a file-event: raise as today; its client `.catch` drops it silently
  (file-events never show the dialog, and its file content is already in the
  concurrent winner). No retry.

WEB side (browser JS in the `.erb` views): the type discriminator is only correct if a
file-event is never the NEWER write in a race with a test, i.e. no file-event may START
during a `[test]` run. This turned out to already hold, with one small exception now
closed:
- File-events cannot fire during a run. Every file-event trigger is a MOUSE action
  (file create/delete/rename buttons, mouse file-select in the list, predict
  checkboxes), and `#wait-overlay` (full-page, `pointer-events` on) blocks all clicks
  during a run. The keyboard file-nav shortcuts (Alt-J/K next/prev, Alt-O toggle)
  deliberately fire NO inter-test-event - by design, to avoid rate-limiting from rapid
  cycling - so keyboard cannot fire a file-event either. So no extra file-event gate is
  needed.
- The one residual was test-vs-test, not a file-event: Alt-T/R/A/G run a test/predict
  via keyboard and bypass the overlay, so pressing one mid-run could start a SECOND
  concurrent test. Both retry and commit (no dialog), but a lost older test could land
  after the newer one (cosmetic reverse order) plus a wasted runner run. Closed by a
  re-entry guard in `cd.kata.runTests` (`_run_tests.erb`): every test-trigger (button,
  predict buttons, all Alt-keys) funnels through it, so one `runTestsInProgress` flag
  covers them all. It gates only the RUN, not a save, so it does not touch the
  resilience constraint (a hung save never blocks editing).
- We deliberately do NOT gate `[test]` while an ITE is in flight (that is the
  resilience-breaking disable/wait we rejected). `[test]` fires freely; the saver
  retry handles a loss.

## Remaining work, by repo

WEB (`cyber-dojo/web`) - browser JS/CSS: DONE (uncommitted in the web tree).
- Phase 3, the cause-2 fix, and the `laptop_id` forwarding.
- The write-during-test resolution (step 2): confirmed `#wait-overlay` blocks all
  mouse clicks during a run and keyboard file-nav fires no ITE, so no file-event gate
  was needed; added the `cd.kata.runTests` re-entry guard for the test-vs-test edge.

SAVER (`cyber-dojo/saver`) - `source/server/model/kata_v2.rb`:
2. DONE (uncommitted): directional retry in `commit_event`'s CAS-loss `rescue` plus
   `COMMIT_EVENT_MAX_RETRIES`. DccG02 (different-laptop reject) and DccG03 (same-laptop
   test retry) pass.
3. DONE (uncommitted): DccG04 covers the directional DROP branch - N concurrent
   same-`laptop_id` file-edits making the same edit at index 1; exactly one commits, the
   CAS-loss losers are dropped as "Out of order event", the log stays contiguous. A
   single mixed file-edit + `[test]` test was rejected as inherently flaky: `ran_tests`
   runs an internal `file_edit` first (`kata_v2.rb:263`), which can itself lose the CAS
   and drop, losing the test event depending on race timing. So the three directions are
   covered separately (DccG02/DccG03/DccG04) rather than in one test. Only
   `attempts >= COMMIT_EVENT_MAX_RETRIES` (retry exhaustion) stays uncovered - it cannot
   be forced deterministically from a client test.

## Deploy dependencies

The false positive is only fully crushed when ALL of these are deployed:
- SAVER: Phase 1 (accept + store `laptop_id`) + Phase 2 (sequential self-lag) + the
  new concurrent CAS-loss retry.
- WEB: Phase 1 (mint + forward `laptop_id`) + cause-2 fix + Phase 3 + the
  write-during-test gate.

Saver-alone fixes nothing: without web forwarding `laptop_id`, the saver falls back to
the legacy index check and every stale solo `[test]` still false-dialogs.
