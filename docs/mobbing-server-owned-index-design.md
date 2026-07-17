# Mobbing false-positive: server-owned index design (Option C)

Status: Phases 1 and 2 are implemented and tested in the `web` and `saver`
working trees (both saver suites - server and client - and the web suites green),
but NOT yet deployed.
- Phase 1 (laptop_id capture): 1.1 saver accepts `laptop_id`, 1.2 web mints the
  cookie and sends it on every write, 1.3 saver stores it on each event when it is
  well-formed.
- Phase 2 (saver detection): `commit_event` uses `laptop_id` to accept a solo
  lost-response (self-lag) write and reject genuine two-laptop mobbing, instead of
  rejecting every stale index.
The remaining work is **Phase 3** (web: let the saver drive placement and retire
the Option A resync apparatus - the browser stops owning the index for placement
but keeps re-setting it to the saver-returned `next_index`) and **Phase 4**
(cleanup). See "Where to pick up next" below for exactly what is left and how to do
it.

This design supersedes Option A (the `GET /kata/next_index/:id` route plus the
client `resyncIndex`, merged as #381 to recover a browser whose owned index fell
behind after a lost inter-test response); Phases 3-4 remove that apparatus.

Before starting: the Option A stopgap (the `next_index` route, `resyncIndex`, and
its two tests) is committed on `main` as `51953982a` ("Fix false 'mobbing?' dialog
for a solo user on an unshared kata", #381). The Phase 1 + Phase 2 changes are
UNCOMMITTED in the `web` and `saver` working trees (modified `app.rb`,
`saver_service.rb`, `model.rb`, `kata_v2.rb`, plus new/edited tests). Confirm the
real state with `git -C web status` and `git -C saver status` before assuming
anything below - and see "Where to pick up next" for what is done vs left.

Governing constraint discovered while building this (it inverts the rollout order
below): the saver does NOT ignore unknown fields. Its dispatch
(`saver/source/server/app_base.rb`, `json_result`) symbolizes every JSON body key
and splats them all as keyword arguments into the target method
(`target.public_send(method_name, **named_args)`), and the write methods in
`saver/source/server/model.rb` declare strict required keywords with no `**`
catch-all (e.g. `def kata_file_create(id:, index:, files:, filename:)`). So a body
carrying an extra `laptop_id:` raises `ArgumentError: unknown keyword: laptop_id`,
which the saver turns into HTTP 500. Therefore the saver must be taught to ACCEPT
`laptop_id` (an optional keyword) BEFORE web ever sends it. The order is
saver-first, then web; it is not "either order is safe".

Detection needs no new field: it reuses the `index` the browser already sends on
every write (see "Detection"). Phase 1 therefore adds only `laptop_id`; detection
(Phase 2) reuses the existing `index`. See the "Code map" and "How to verify locally" sections at
the end for where the current mechanism lives and how to drive it.

## Where to pick up next

DONE (in the `web` and `saver` working trees, tested, undeployed):
- saver: `model.rb` accepts optional `laptop_id`; `kata_v2.rb` `commit_event`
  stores it when well-formed and does the detection - `if laptop_id.nil?` keeps
  today's index check, else it places at `head + 1` and rejects an ahead-of-head
  index or a different `laptop_id` among the events in `index .. head`, accepting a
  same-laptop stale write (self-lag). Tests:
  `saver/test/server/kata_mobbing_detection.rb` (Mb7D01 self-lag accept, Mb7D02
  genuine-mobbing reject, Mb7D03 ahead reject, Mb7D04 handoff accept, Mb7D05
  nil-path reject) and end-to-end via the client
  `saver/test/client/kata_laptop_id_test.rb` La7C03.
- web: `app.rb` mints the `laptop_id` cookie (before-hook, mirrors `csrf_token`)
  and exposes `attr_reader :laptop_id`; `saver_service.rb` reads
  `externals.laptop_id` and adds it to the 9 event-write bodies. Tests:
  `laptop_id_cookie_test.rb`, `saver_service_forwards_laptop_id_test.rb`.

KEY FRAMING: the false-positive fix is delivered by DEPLOYING the above (saver
detection + web sending `laptop_id`), NOT by Phase 3. Once deployed, a solo
lost-response [test] sends a stale index plus its own `laptop_id`, and the saver
accepts it as self-lag - no dialog. Phase 2 detection is a superset of Option A's
coverage (it also fixes the slow-[test]-retry case Option A never closed), so
Option A becomes fully redundant. Deploy order is saver-first (with `nil`
laptop_id it is byte-identical to today - see "Deploy safety"), then web (sending
`laptop_id` activates detection); both are only ever more-permissive than today.

THE REMAINING WORK is Phase 3 (web: let the saver drive the indexing) + Phase 4
(cleanup) - the Option C end-state, all of it behavior-neutral once the above is
deployed and soaked. Two parts: (i) remove the Option A resync (`resyncIndex` + the
browser's `next_index` call); (ii) for consistency with Option C's principle that
the browser ALWAYS adopts the saver-returned index and never computes a position
itself, switch the last two paths that still compute locally (`[checkout]` /
`[revert]` / auto-revert, via `incrementIndex()`) to re-set from the saver response,
then delete `incrementIndex`. Part (ii) is behavior-neutral today - those paths are
always +1 and the local `+1` is already correct - so it is cleanup, not a fix:
- Today web derives its next-event index two ways: (a) it re-sets `index` from the
  saver's response on every write - `setIndex(light.index + 1)` (`_run_tests.erb`)
  and `.then(newIndex => setIndex(newIndex))` (`_file_inter_test_events.erb`), plus
  the `setIndex(events.length)` page-load reset (`edit.erb`) - and (b) the Option A
  resync (`resyncIndex` + the `GET /kata/next_index/:id` route) for a lost response.
  Under C the saver drives placement (`head + 1`) and returns the resulting
  `next_index` (derived from the committed head), so (a) STAYS - the browser keeps
  re-setting `index` to that returned value and thus tracks the committed head,
  with `index` now only a detection high-water mark, not authoritative for
  placement - and (b) is removed (self-lag + a refresh recover a lost response
  instead). The `setIndex` helper (`_index.erb`) stays; `incrementIndex` is removed
  once `revert()` and `cd.revertOrCheckout` switch to `setIndex` (see the Phase 3
  bullet below).
- Phase 3 (web): rely on the saver's placement (`head + 1`) and its returned
  `next_index`. KEEP the response-driven re-set (`setIndex(light.index + 1)` in
  `_run_tests.erb`, `.then(newIndex => setIndex(newIndex))` in
  `_file_inter_test_events.erb`): the saver decides placement and returns the
  `next_index` derived from the committed head, and the browser re-sets `index` to
  that value on every write. A local `+1` would be WRONG because one action can
  advance the head by 2 (`file_edit` runs first inside `ran_tests`/`file_*`, so it
  can commit its own event before the main one). Two remaining paths still compute
  the index locally with `incrementIndex()`: (a) auto-revert on a wrong prediction
  (`revert()` in `_run_tests.erb`, POST `/kata/revert`); (b) the `[checkout]` and
  `[revert]` buttons (both call `cd.revertOrCheckout` in
  `review/_checkout_button.erb`, POST `/kata/checkout`). These are always +1
  (`reverted`/`checked_out` commit exactly one event - they do NOT call `file_edit`
  first, unlike `ran_tests`/`predicted_*`/`file_*`), so the local `+1` is already
  correct and there is NO bug. Phase 3 still switches them to
  `setIndex(data.light.index + 1)` (each response already carries
  `light.index == next_index - 1`) purely for consistency with Option C's principle
  that the browser adopts the saver-returned index rather than computing a position
  itself; this is behavior-neutral, not a fix. Once both call sites re-set from the
  response, `incrementIndex` (`_index.erb`) is dead and is removed. What Phase 3
  removes is the
  Option A recovery apparatus: `resyncIndex` and its `.catch(() => resyncIndex())`,
  so the browser stops CALLING the `next_index` route (the route itself is removed
  later, in Phase 4). On a lost response the browser leaves `index` stale; the
  saver self-lag-accepts the next write (same `laptop_id`) and a refresh re-syncs
  via `edit.erb`. Keep sending `index` (the observed high-water mark) purely as the
  detection signal. Phase 3 must preserve the invariant that a saver failure still
  returns the runner's traffic-light (the `run_tests` rescue - see "What does NOT
  drop away").
- Phase 4 (contract, after a soak so no old-JS browser still calls it): remove the
  `GET /kata/next_index/:id` route and its test `kata_next_index_test.rb`. (The
  old `mobbing_resync_after_lost_event_test.rb` was already re-worked in Phase 3
  into `mobbing_self_lag_after_lost_event_test.rb`, which asserts the saver
  self-lag path and STAYS.)
- Verify Phase 3 by driving the stack (see "How to verify locally"): a lost
  inter-test response followed by a [test] shows no dialog; a genuine two-laptop
  interference still does.

## The problem

The "mobbing?" dialog is meant to fire only when two or more laptops share a
kata-id and their [test] submissions interfere. Today a single user working alone
can trigger it. The browser owns its next-event `index` (a hidden field) and
advances it only from a successful response, so a lost or aborted inter-test
response, whose event the saver still committed, leaves the browser's index behind
the committed head. The next [test] sends that stale index, which the saver
rejects as an `"Out of order event"` and the browser renders as a false dialog.
(nginx rate-limiting is not involved: a 429 is rejected before it reaches the
saver, so it never commits and never desyncs the index.)

## The idea

Today the browser-sent `index` does double duty: it decides where the event is
written (correctness) AND it is the mobbing signal (a mismatch raises
`"Out of order event"`). That coupling is the root of the whole false-positive
class. Option C splits them:

- Correctness (placement): when a write is accepted it is placed at `last + 1`,
  server-decided; the browser's index never decides placement. A lost response
  can no longer poison anything, because the browser never asserts a position
  that can be wrong.
- Detection: becomes its own explicit check, driven by per-laptop identity rather
  than by an index mismatch (see "Detection" below) - and it, not a stale index,
  is what can reject a write.

## The two halves behave differently

- The correctness half ("append at last+1, ignore the browser index") would
  function on its own: nobody ever gets a spurious `"Out of order event"` again.
- But it is NOT shippable on its own, because that index check IS today's entire
  mobbing detection. Remove it and append blindly, and two genuinely-sharing
  laptops interleave their events silently, with no dialog ever. That fixes the
  false positive by deleting the feature.

So Option C requires a replacement detection signal that does not rely on an
index mismatch. That signal is per-laptop identity: stamp each event with the id
of the laptop that wrote it, so the saver can tell one laptop's events from
another's. This id machinery is part of C.

## Per-laptop id

A per-browser id, minted and set as a cookie exactly like the existing
`csrf_token` in `app.rb` (read the cookie; if absent generate `SecureRandom.hex`
and Set-Cookie). It is:

- stable across reloads (persists), so a refresh keeps the same id;
- distinct per browser, so two laptops get different ids;
- independent random, so it is not derivable from kata-id or avatar (which are
  shared during genuine mobbing) and can actually distinguish two laptops;
- sent automatically on every request, no per-fetch wiring.

The web layer forwards it to the saver on each write, so every event is stamped
with the laptop that wrote it. Default to a session-scoped cookie (cleared on
browser close), which is enough for stability across reloads.

## Detection

Every committed event is stamped with the writing laptop's id (the cookie above).

Detection needs NO new argument: it reuses the `index` the browser already sends
on every write. That `index` is the position the browser thinks its next write
takes - one past the highest committed index it has observed. C stops treating
`index` as authoritative for PLACEMENT but keeps receiving it and reuses it as
the detection signal.

The saver, on each write, first inspects the committed events in `index .. head`
(the events that landed since this browser last looked) to decide the verdict:

- range empty (`index == head + 1`), or every event in it written by THIS
  `laptop_id` (the browser's own not-yet-observed writes) -> no mobbing ->
  append the new event at `last + 1` (server-authoritative placement, ignoring
  the client `index`), return `next_index`, no dialog.
- any event in the range written by a DIFFERENT `laptop_id` -> another laptop got
  in -> genuine mobbing -> REJECT: do not append, `events.json` is unchanged, and
  the write response carries the mobbing dialog (same outcome as today).

So placement is server-authoritative (`last + 1`) on an accepted write, and a
stale client `index` alone never rejects a write - only a differing `laptop_id`
in the range does. This preserves today's invariant that a genuinely-interfering
write is never persisted, while removing the solo lost-response false positive
(range non-empty but entirely the browser's own id).

Because `index` already carries this, no separate marker and no per-laptop
server-side cursor is needed; the browser keeps sending `index`, demoted from
authoritative-position to detection signal.

## What drops away (the win)

- The browser index being AUTHORITATIVE FOR PLACEMENT. Today the saver requires
  `index == last + 1` and writes at the client's `index`; under C the saver decides
  placement itself (`head + 1`) and ignores the client `index` for placement. The
  `index` field STAYS and so does the response-driven re-set:
  `setIndex(light.index + 1)` in `_run_tests.erb` and
  `.then(newIndex => setIndex(newIndex))` in `_file_inter_test_events.erb` re-sync
  the browser to the `next_index` the saver returns (derived from the committed
  head), so `index` keeps tracking the highest committed index the browser has
  observed - which IS the saver-returned value. This re-set is REQUIRED, not
  removed: one logical action can advance the head by 2 (`file_edit` runs first
  inside `ran_tests`/`file_*`), so a local `+1` would drift. What changes is only
  the MEANING of the value - a detection high-water mark, no longer an authoritative
  write position. `setIndex` is kept (the page-load reset in `edit.erb` and the
  per-write re-set); `incrementIndex` is removed once its `revert()` /
  `cd.revertOrCheckout` call sites switch to `setIndex`.
- The entire desync class and everything built to cope with it, including all the
  Option A machinery: the `GET /kata/next_index/:id` route (`app.rb`) and
  `resyncIndex` (`_file_inter_test_events.erb`) exist ONLY because the browser
  owns the index. Under C they are dead and are deleted, along with the route test
  `kata_next_index_test.rb`. (The resync-recovery test
  `mobbing_resync_after_lost_event_test.rb` was re-worked in Phase 3 into
  `mobbing_self_lag_after_lost_event_test.rb`, which asserts the saver self-lag
  path C relies on and STAYS.) The route is net-new (added
  for Option A this session), so its complete consumer set is the code that was
  added with it; removing it touches no other repo and needs no nginx change.
- The saver's client-supplied index check (`index == last['index'] + 1`) as a
  correctness gate.

Removal order matters: C drops the browser-owned index, which makes `resyncIndex`
meaningless, and only then is the `next_index` route dead. The route cannot be
removed while the client still calls it.

## What does NOT drop away

- The concurrency machinery stays. "Append at head + 1" is computed server-side,
  but two concurrent writes to one kata still both observe `head = N` and both try
  to write `N + 1`. The in-process-git compare-and-swap in `commit_event`
  (documented in `saver` `config/puma.rb` and `docs/in-process-git.md`) is what
  serializes them. It has nothing to do with the client index and must remain.
  GAP - NOT yet implemented (do not assume otherwise): the `laptop_id` self-lag
  verdict lives ONLY inside the `commit_on_main` block (the sequential path). The
  CAS loser is handled by `commit_event`'s method-level `rescue`, which re-reads
  the tip and, if it advanced to `>= index`, raises "Out of order event" with NO
  `laptop_id` check and NO retry. So two CONCURRENT writes from the SAME laptop
  (eg cause 1: a `[test]` fired by `waitForITE`'s 2s bail while an inter-test event
  is still in flight) reject the loser as mobbing -> false dialog. Fully closing
  this needs the CAS-loss rescue to run the same `laptop_id` verdict over
  `index .. head` and, when the racing events are all this same laptop's own, RETRY
  the append at the new `head + 1` (only a DIFFERENT laptop_id should reject). Until
  that retry exists, the concurrent same-laptop case is NOT covered by self-lag; the
  web-side alternative is to stop the concurrency (do not let `waitForITE` fire
  `[test]` while an inter-test write is in flight).
- The `index` field on the wire stays - it IS the detection signal (no separate
  marker, no server-side cursor; see "Detection"). It changes role from
  "authoritative next-write position" to "high-water mark I have observed", used
  only for detection. So the
  accurate framing is "the browser stops OWNING the index", not "the index is
  gone".
- The per-laptop id machinery (the cookie above).
- INVARIANT: a saver failure never loses the runner result. `run_tests`
  (`app.rb` ~155-216) runs the runner first, then wraps ONLY the saver save in
  `begin ... rescue SaverService::Error`, and returns the runner's traffic-light
  (outcome/stdout/stderr) in the response regardless - so if the saver is down or
  rejects the write, the browser still shows the light; it is just not persisted
  (lost on refresh). C surfaces its reject-on-mobbing through this same
  `SaverService::Error` path, so the behaviour is preserved for free. But Phase 3
  reworks `run_tests`'s index handling (it currently fabricates
  `next_index = index + 1` from the sent index on the rescue path), so that rework
  MUST keep the run-runner-then-rescue-the-save structure and keep returning the
  light on failure. Treat this as an invariant to test, not an accident to
  inherit.

## Where the trickiness relocates

From client sync code into the server detection check. Today detection is a free
side effect of the append failing; under C it is explicit logic ("head moved past
the browser's `index`, and an intervening event carries a different laptop_id ->
dialog"). That is the part with regression risk: get it slightly wrong and you
either miss real mobbing or reintroduce false ones. Net trickiness likely goes
down, but it moves rather than vanishes.

## Handoff and browser-switch (must still hold under C)

A legitimate handoff or same-laptop browser-switch re-enters the kata and loads
the edit page, which renders current state and sets the browser's `index` to
`head + 1`. So the taking-over browser's `index .. head` range is empty and no
dialog fires, regardless of id. This is the same "a session that re-syncs is
fine" invariant. If the OLD browser is left open and used again after the new one
committed events, its `index` is now behind the head and the intervening events
carry a different id, so it is correctly flagged: two live sessions interfering is
what the dialog is for.

## Edge cases

- Two tabs, one laptop: same cookie, same id, treated as self (no dialog). Matches
  the feature's intent ("two or more laptops").
- Cookie cleared / incognito / new browser mid-kata: new id, but the page load
  sets `index` to `head + 1`, so the range is empty and the id is never examined.
- Legacy events (committed before C ships, no laptop_id): the saver cannot prove
  an intervening event is "mine", so it must fail toward the dialog, which is
  today's behavior. Backward compatible and safe (never silently interleave two
  real laptops).

## Rollout plan (expand / contract)

Only web and saver change (nginx and the other services are untouched). The
sequence is expand/contract so mobbing detection is never silently lost mid-deploy.

Two ordering facts, in tension, fix the sequence:

- The saver REJECTS an unknown `laptop_id` keyword (the governing constraint at the
  top of this doc: strict-kwarg dispatch -> HTTP 500). So the saver must ACCEPT the
  field before web sends it.
- The saver cannot originate `laptop_id` (it is a web-minted cookie). So the saver
  cannot store or act on it until web is sending it.

Together these mean: saver-accepts first, then web-sends, then saver-stores/acts.
Each step is safe against the deployed version of the other side.

Phase 1 - capture (prime the data), no user-visible change:

- Step 1.1 saver (deploy first): add an optional `laptop_id: nil` keyword to the 9
  event-committing write methods in `model.rb` (`kata_file_create`,
  `kata_file_delete`, `kata_file_rename`, `kata_file_edit`, `kata_ran_tests`,
  `kata_predicted_right`, `kata_predicted_wrong`, `kata_reverted`,
  `kata_checked_out`) so the dispatch no longer raises on the extra key. Do NOTHING
  with the value yet - accept and drop it. Detection is unchanged (still the index
  check, still raises today). This is the "expand" that lets web send the field
  safely; it is a no-op for both old web (no field) and new web (field present).
- Step 1.2 web (deploy after saver is live): mint the `laptop_id` cookie in
  `app.rb`, mirroring the `csrf_token` block (read the cookie; if absent mint
  `SecureRandom.hex(32)` and Set-Cookie), then forward `laptop_id` to the saver on
  all 9 event-writes. Forward only `laptop_id` (the browser already sends `index`);
  detection is deferred to Phase 2. Change nothing else: the browser still owns and
  sends the authoritative index, `resyncIndex` and the `next_index` route stay.
  Safe because Step 1.1 already made the saver accept the field.
- Step 1.3 saver (deploy after web is live): store `laptop_id` on each committed
  event, but only when it is well-formed - the 64-char lowercase-hex minted
  format (`SecureRandom.hex(32)`, validated at the saver, which owns the log and
  does not trust input). A nil, absent, or malformed laptop_id stores NO
  `laptop_id` key at all, so such an event is indistinguishable from a legacy
  pre-1.3 event - there is a single representation of "unknown writer" (key
  absent), never a stored `null` or untrusted value. The value is threaded through the write
  path to the one commit point (`kata_v2.rb` `commit_event`) and added to the
  stored event beside `index`/`time`; the index-0 create event is written by
  `kata_create`, not this path, so it carries no `laptop_id`. Detection is still
  unchanged - the saver only records who wrote each event. Note the `laptop_id: nil`
  default on the web-facing methods is transitional: once all clients send a
  laptop_id, that default is removed and the field becomes required. Design this
  step only once 1.1 and 1.2 are in place; events written between 1.2 and 1.3
  carry no stored id and are treated as legacy.
- Net effect: events begin carrying the writing laptop's id; users see no change;
  the history needed for detection starts accumulating.

Phase 2 - saver, switch detection to dual-mode: DONE (implemented + tested in the
saver working tree, undeployed). `commit_event` uses the `laptop_id` verdict
(inspect `index .. head`) when `laptop_id` is present; otherwise it falls back to
today's index check (`if laptop_id.nil?` branch - legacy events or requests
without a laptop_id). In the new mode an accepted write is placed at `last + 1`
(the client `index` never decides placement), and a differing `laptop_id` in the
range rejects the write (not saved) exactly as today. The only behaviour change
is more-permissive: the solo lost-response case (range all the browser's own id)
now succeeds instead of being rejected; genuine mobbing is rejected as before.
Also: `git_commit_tag_sss`'s `next_index` is now derived from the committed head
(`all_events.last['index'] + 1`) and the tag from `place_at`, so an accepted
stale write reports the real next index. Tests in `kata_mobbing_detection.rb`.

Phase 3 - web, stop the browser OWNING the index for placement: rely on the
server-decided placement (`head + 1`) plus the rejection verdict (the
`out_of_sync` dialog). KEEP re-setting `index` to the saver-returned `next_index`
on every write (the `setIndex` calls in `_run_tests.erb` and
`_file_inter_test_events.erb`) - that is how the browser tracks the committed head,
and a local `+1` would drift because one action can be +2. For consistency (the
browser adopts the saver-returned index, never computes locally), also switch the two
paths that still use a local `incrementIndex()` - `revert()` (auto-revert on a wrong
prediction) and `cd.revertOrCheckout` (the `[checkout]`/`[revert]` buttons) - to the
same `setIndex(data.light.index + 1)`, then remove the now-dead `incrementIndex`.
These paths are always +1 (`reverted`/`checked_out` do NOT call `file_edit`), so this
is behavior-neutral cleanup, not a fix. Remove the Option A recovery:
`resyncIndex` and its `.catch(() => resyncIndex())`, so the browser stops calling the
`next_index` route (the route is removed in Phase 4). The browser still
sends `laptop_id` + `index`, but `index` is now a detection high-water mark, not an
authoritative write position. Safe once Phase 2 is live, because the saver already
places at `head + 1` for id-bearing requests.

Phase 4 - contract, cleanup (after a soak so no old-JS browser session can still
call `next_index`): web removes the `next_index` route and its test
`kata_next_index_test.rb`; saver removes the old index check, collapsing dual-mode
to single-mode. (`mobbing_resync_after_lost_event_test.rb` is not removed here - it
was re-worked in Phase 3 into `mobbing_self_lag_after_lost_event_test.rb`.)

## Deploy safety

Both web and saver change, so both crossovers matter.

- A normally-progressing user has an empty `index .. head` range (index ==
  head + 1), so the detection logic is a no-op for them and they see no change.
- A stale range over legacy events falls back to today's behavior (dialog).
- The `laptop_id` field is NOT silently ignored by an unprepared saver: its
  strict-kwarg dispatch raises HTTP 500 on an unknown key (see the constraint at
  the top of this doc). Safety therefore comes from ordering, not from the field
  being inert - Step 1.1 makes the saver accept `laptop_id` before Step 1.2 has web
  send it, so no crossover ever has web sending a field the deployed saver rejects.
  Once accepted, the field is additive at the storage layer: it is stored only
  when present, so old (legacy) events and nil-write events alike simply have no
  `laptop_id` key, which reads back as absent/nil; no migration, `events.json`
  stays the single source of truth both versions read.
- The invariant to enforce: the id/index detection logic may only make the saver
  MORE permissive than today, never less. No write that succeeds today may fail
  after C lands.
- The dropped `next_index` route: an old browser (pre-C web) still calls it, so the
  route must not be removed until no deployed browser session can still call it.
  That is why it is a Phase 4 (contract) step, gated on a soak, not part of the
  Phase 3 web deploy that stops calling it. See the Rollout plan above.

## Assumptions

- Event indices are contiguous `0..N`, so `head == last_index` and
  `events.length == last_index + 1`.
- The saver is the single source of truth for a kata's committed state.
- `laptop_id` identifies a browser/laptop, not a kata or avatar, and is stable
  across reloads (a cookie).
- The `index` the browser sends is truthful: one past the highest committed index
  it has rendered (set to `head + 1` on page load).

## Tests to write when building Option C

- Accepted-write placement ignores a stale client index: with the range all the
  browser's own id (or empty), a write whose client index is stale/absent is still
  appended at `head + 1`, not the client index.
- Detection: an empty `index .. head` range is accepted, no dialog (normal
  progress and refreshed handoff).
- Detection: a range whose events all carry the requester's laptop_id is accepted,
  no dialog (the browser's own not-yet-observed writes, the old desync scenario).
- Detection: a range containing a different laptop_id is REJECTED and not saved,
  with the dialog (genuine two-laptop interference) - `events.json` unchanged.
  (Concurrency caveat: this self-lag verdict runs only in the SEQUENTIAL path. The
  CAS-loss rescue does NOT yet do it - it rejects any concurrent loser whose tip
  advanced to `>= index`, same laptop or not. The saver `DccG02` concurrent-saves
  test asserts the loser fails. Making a same-laptop concurrent loser
  retry-and-succeed is the UNIMPLEMENTED fix described in the "concurrency
  machinery" bullet under "What does NOT drop away".)
- Legacy events (no laptop_id) in the range are rejected (dialog), as today.
- After C, the `next_index` route and `resyncIndex` are gone (grep is clean); the
  route test `kata_next_index_test.rb` is removed, and the resync test is re-worked
  into the self-lag guard `mobbing_self_lag_after_lost_event_test.rb`.

## Code map (current mechanism, the code C changes)

Line numbers are approximate; grep the symbol if they have drifted.

web (`web/source/app/`):
- `app.rb:155` `post '/kata/run_tests/:id'` - the only handler that surfaces
  mobbing. It calls the saver, rescues `SaverService::Error`, and at `app.rb:192`
  sets `@out_of_sync = error.message.include?('Out of order event')`, returned as
  `out_of_sync:` (`app.rb:213`). The file event routes (`file_create` etc, ~132)
  do NOT map the error, so only [test] shows the dialog.
- `app.rb:333` `def index` reads the browser-sent index; `app.rb:342` `ran_tests`
  dispatches to the saver. C makes the saver ignore this for placement.
- `app.rb:306` `get '/kata/next_index/:id'` - the Option A stopgap route (delete
  in Phase 4).
- `views/kata/_index.erb:13,18` `incrementIndex`/`setIndex` - the browser's index
  helpers. `setIndex` STAYS (the page-load reset and the per-write re-set to the
  saver-returned value). `incrementIndex` is removed in Phase 3 once its two call
  sites (`revert()` and `cd.revertOrCheckout`) switch to `setIndex`.
- `views/kata/_run_tests.erb` - `setIndex(light.index + 1)` on a successful test
  (re-sets to the saver-returned index, retained under C); reads the `out_of_sync`
  flag and calls `cd.mobbingPoll.check()` to lock the tab. Phase 3 consistency change:
  `revert()` (`:113`, the auto-revert-on-wrong-prediction path, POST `/kata/revert`)
  advances via a local `incrementIndex()`. `reverted` commits exactly one event (it
  does NOT call `file_edit` first), so the local `+1` is already correct - no bug.
  Switch it to `setIndex(data.light.index + 1)` anyway, so every write path adopts
  the saver-returned index (Option C's principle); behavior-neutral cleanup.
- `views/review/_checkout_button.erb:45` `cd.revertOrCheckout` - the shared handler
  for the `[checkout]` AND `[revert]` buttons (POST `/kata/checkout`). Advances the
  index via a local `incrementIndex()` (`:69`); `checked_out` is also always +1
  (no `file_edit`), so this too is correct today. Phase 3 switches it to
  `setIndex(data.light.index + 1)` for the same consistency reason as `revert()`
  above.
- `views/kata/_file_inter_test_events.erb:80` `setIndex(newIndex)` on success -
  RETAINED (re-sets to the saver-returned index). `:86` `.catch(() => resyncIndex())`
  and `:90` `resyncIndex` (Option A) are removed in Phase 3 (the `.catch` becomes a
  no-op; a lost response recovers via saver self-lag + a refresh). Also holds the
  in-progress flag for every inter-test event.
- `views/kata/edit.erb:29,35` embeds the events array and runs
  `setIndex(events.length)` on load - this is the resync-on-refresh that makes
  handoff safe; under C the same `index` becomes the detection high-water mark.

saver (`saver/source/server/model/kata_v2.rb`) - Phase 2 is implemented here:
- `commit_event` is the write path. Inside the `commit_on_main` block it branches:
  `if laptop_id.nil?` keeps today's check (`raise "Out of order event"` when
  `index != last + 1`, place at `index`); else it sets `place_at = head + 1`,
  raises when `index > place_at` (ahead) or when any event in `index .. head` has a
  different `laptop_id` (mobbing), and otherwise accepts (self-lag) - placing the
  event at `place_at`. The two-layer comment above the method documents this. The
  method-level `rescue` handles the concurrent (CAS-loss) case: it re-reads the tip
  via git and rejects the loser when the tip advanced to `>= index` - with NO
  `laptop_id` check and NO retry, so a concurrent same-laptop loser is falsely
  rejected (the concurrency GAP under "What does NOT drop away").
  `valid_laptop_id?` (64-hex) gates whether `laptop_id` is stored on the event.
- `git_commit_tag_sss` derives `next_index` from `all_events.last['index'] + 1`
  and `create_tag` uses `place_at`, so an accepted stale write reports/tags the
  real committed index.
- `:471` `git update-ref ... <new_oid> <base_oid>` is the compare-and-swap that
  serializes concurrent writes - the concurrency mechanism that STAYS.
- `file_edit` (`:238`) runs first inside `ran_tests` (`:262`) and can itself
  commit an event, so one logical action can advance the head by 2.
- `config/puma.rb` and `docs/in-process-git.md` document the CAS model.
- Concurrency proving test: client test `DccG02`
  (`saver/test/client/kata_concurrent_saves_test.rb`).

nginx (`nginx/nginx.conf.template`): file/test routes are rate-limited
(`kata_file_* 1r/m`, `kata_file_edit 6r/m`, `run_tests 6r/m` keyed by `$uri`,
all `nodelay`). No change needed for C. A 429 never reaches the saver.

## How to verify locally

The working tree is served into the containers, but note two gotchas that cost
time otherwise:

- `web-web-1` runs Puma in production mode (no auto-reload). After editing
  `app.rb` you must `docker restart web-web-1` for a route change to take effect.
  Mounted `.erb` views re-render per request, so view edits are live.
- The saver does NOT refresh its git working tree on write (reads go via git). To
  see a kata's real committed state, read through git, not the file:
  `docker exec web-saver-1 bash -c "cd /cyber-dojo/katas/<P1>/<P2>/<P3> && git show main:events.json | jq ."`
  (a kata id `abcdef` maps to `ab/cd/ef`). `cat events.json` shows STALE data.

Bring up the full stack (nginx + web + saver + deps), which activates the real
rate-limiting layer:

```
cd web && make demo          # builds web, creates a seeded v2 kata, opens it
```

`create_v2_kata.rb` seeds a kata with a full demo history (head at index 11), not
an empty one. Make a fresh one for a clean run:

```
docker exec --env CYBER_DOJO_SAVER_CLASS=SaverService web-web-1 \
  bash -c "ruby /web/source/script/create_v2_kata.rb 1"   # prints the new id
```

Drive the saver JSON API directly (port 4537 inside the container; no curl in the
saver image, so use ruby Net::HTTP): POST `/kata_ran_tests`, `/kata_file_create`,
etc with a JSON body `{id:, index:, files:, ...}`. On an out-of-order the saver
returns HTTP 500 with body `{"exception":"Out of order event for <id>"}`.

Run one controller test file against the running saver (RunnerStub avoids the real
runner); do NOT use `bin/run_tests.sh`, which tears the stack down and up:

```
docker exec --user nobody \
  -e RACK_ENV=test -e CYBER_DOJO_SAVER_CLASS=SaverService \
  -e CYBER_DOJO_RUNNER_CLASS=RunnerStub \
  -e COVERAGE_DIR=/tmp/cyber-dojo/coverage/app_controllers \
  web-web-1 sh -c 'mkdir -p /tmp/cyber-dojo/coverage/app_controllers && \
    cd /web/source/test/app_controllers && \
    ruby -e "require \"../test_coverage.rb\"; require \"./<file>_test.rb\"" app_controllers'
```

Or the whole module (no stack teardown):
`docker exec --user nobody web-web-1 sh -c 'cd /web/source/test && ./run.sh app_controllers'`.

Already verified this way in the design session: the false-mobbing reproduction
(stale index -> HTTP 500 out-of-order) and the handoff baseline (Laptop A drove a
kata to head 11; Laptop B's refresh synced to index 12 and its [test] saved
cleanly; the same [test] at the pre-refresh index 11 raised out-of-order).
