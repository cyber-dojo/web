# Mobbing false-positive: per-laptop-id design (Option B)

Status: design only, not implemented. Option A (below) is implemented and shipped.

## The problem

The "mobbing?" dialog is meant to fire only when two or more laptops share a
kata-id and their [test] submissions interfere. A single user working alone on
an unshared kata could trigger it too.

Mechanism (verified on a running stack):

- The browser holds its own next-event `index` (a hidden field, see
  `_index.erb`) and advances it only from a successful response.
- An inter-test file event (create/delete/rename/edit) posts at that index and,
  when its response is lost (fetch abort, network drop) while the saver still
  committed the event, the browser never applies the returned index. The
  browser's `index` is now behind the committed head.
- The next [test] sends that stale index. The saver's check
  (`kata_v2.rb`, `index == last['index'] + 1`) fails and raises
  `"Out of order event"`, which `app.rb` turns into `out_of_sync: true` and the
  browser renders as "mobbing?".

Ruled out: nginx rate-limiting. A 429 is rejected at nginx before it reaches the
saver, so it never commits and never desyncs the index (verified: a rapid burst
of file_create posts returned 403/429 and the committed head was unchanged).

## Governing constraint

The client-owned index does double duty: correctness bookkeeping AND the mobbing
signal. At the saver, a genuine collision and a solo lost-response are identical:
both look like "your index is behind the head". Any fix must either stop the solo
case from desyncing the counter, or give the saver a way to tell the two apart.

## Option A (implemented): client resync on a lost inter-test response

Web-only, saver untouched.

- New `GET /kata/next_index/:id` returns `last_committed_index + 1`, the
  authoritative index a browser resyncs to. Proving tests: `q7F3a1`, `q7F3a2`
  in `test/app_controllers/kata_next_index_test.rb`.
- On a lost/failed inter-test response the client resyncs its index from that
  endpoint instead of leaving it stale (`_file_inter_test_events.erb`,
  `resyncIndex`). Recovery proving test: `kT9mB2` in
  `test/app_controllers/mobbing_resync_after_lost_event_test.rb`.
- The in-progress flag is held for every inter-test event (not just file_edit),
  so a following [test] waits behind an in-flight file op.
- The inter-test abort was raised from 2s to 30s (it was not guarding a rate
  limiter and was the main trigger for abandoning a commit that actually landed).

What Option A does NOT close: any other path where the browser's index legitimately
lags the head, most notably a slow [test] whose response is lost and is then
re-run by the user at the same (now stale) index. Option A only covers the
inter-test path.

## Option B: per-laptop id, discriminate self-lag from another laptop

The distinguishing signal for genuine mobbing is not a token on the current
request; it is who wrote the events sitting between the browser's index and the
head. Tag every committed event with the writing laptop's id. When a save arrives
with a stale index, inspect the events in `(index .. head]`:

- all written by THIS laptop id -> the browser's own committed-but-unacknowledged
  writes -> accept / resync silently, no dialog.
- any written by a DIFFERENT laptop id -> genuinely another laptop -> raise, show
  the dialog.

This makes the dialog mean exactly "two laptops interfered". It closes the whole
class (the inter-test case AND the slow-[test]-retry case), because both are "my
own session got ahead of my browser's counter".

### The invariant that keeps it safe

The id logic may only RELAX a stale-index verdict, never trigger a new one. The
non-stale path (`index == head + 1`) is untouched. Consequences:

- A normally-progressing user (always sends `head + 1`) never hits the examined
  path, so the id is never even looked at.
- The saver can only become more permissive than today, never less. No request
  that succeeds today can fail after Option B lands.

### Where the per-laptop id comes from

Mirror the existing CSRF-token cookie pattern in `app.rb`:

```ruby
before do
  @csrf_token = request.cookies['csrf_token']
  unless @csrf_token
    @csrf_token = SecureRandom.hex(32)
    response.set_cookie('csrf_token', value: @csrf_token, path: '/')
  end
```

Add a parallel `laptop_id` cookie the same way, then forward it to the saver on
every write so each event is stamped with the laptop that wrote it. A cookie
satisfies every constraint:

- Stable across reloads (persists), so a refresh keeps the same id. This is what
  stops a solo user's own mid-kata refresh from becoming a false positive.
- Distinct per browser, so two laptops get different ids.
- Independent random, so it is not derivable from kata-id or avatar (which are
  shared during genuine mobbing) and can actually distinguish two laptops.
- Sent automatically on every request, no per-fetch JS wiring.

Default to a session-scoped cookie (cleared on browser close); that is enough for
stability across reloads. A localStorage UUID sent as a header is an alternative
if survival across browser-close is wanted, but it needs explicit JS on each save.

### Handoff and browser-switch correctness

A legitimate handoff goes through a re-enter plus refresh. The edit page embeds
the events array and runs `setIndex(events.length)` (`edit.erb`), syncing the new
browser to `head + 1`. A refreshed browser is never stale, so its id is never
examined. Verified on the stack: after Laptop A drove a kata to head index 11,
Laptop B's refresh synced to index 12 and its [test] saved cleanly
(`HTTP 200, mobbing=false`), while the same [test] at the pre-refresh index 11
raised `"Out of order event"`.

Switching browser on one laptop is mechanically identical: the new browser has a
different id but re-syncs on load, so it behaves like a rotation to another
laptop and works. If the OLD browser is left open and used again after the new one
committed events, it is genuinely stale against events with a different id and is
correctly flagged: two live sessions on one kata are interfering, which is what
the dialog is for.

Invariant in one line: a session that re-syncs (refreshes) is fine regardless of
id; the id only adjudicates a stale index, i.e. a session that got left behind.

### Edge cases

- Two tabs, one laptop: same cookie, same id, treated as self (no dialog). Matches
  the feature's stated intent ("two or more laptops"). Conscious call, not an
  accident.
- Cookie cleared / incognito / new browser mid-kata: new id, but that path goes
  through a page load that re-syncs the index, so it is not stale and the id is
  never examined. Safe.
- Legacy events (committed before Option B ships, no `laptop_id`): the saver
  cannot prove they are "mine", so it must fail toward the dialog, which is
  exactly today's behavior. Backward compatible and errs on the safe side (never
  silently interleave two real laptops).

### Deploy safety (the saver changes this time)

An in-progress kata will not get a spurious mobbing just because Option B lands,
given the invariant above and an additive field:

- A normally-progressing (non-stale) user is never examined, so sees no change.
- A stale index over legacy events falls back to today's behavior.
- The `laptop_id` field is additive: an old saver instance ignores the extra key
  on new events; a new instance defaults the missing key on old events. No
  migration, no format break, `events.json` stays the single source of truth.
- Rolling window with mixed old/new saver instances: a request handled by an old
  instance runs today's check, so worst case is today's behavior.
- Deploy order of web vs saver does not matter: a missing id always degrades to
  today's behavior.

## Assumptions

- Event indices are contiguous `0..N`, so `events.length == last_index + 1`
  (relied on by both the resync endpoint and `edit.erb`).
- The saver is the single source of truth for a kata's committed state; the
  browser index is a shadow that can and does lag.
- The `laptop_id` genuinely identifies a browser/laptop, not a kata or avatar.

## Tests to write when building Option B

- A non-stale, normally-progressing user is never subjected to the id check
  (commits succeed unchanged, id is stamped).
- A stale range whose events all carry the requester's id is accepted (resync),
  no `out_of_sync`.
- A stale range containing a different id raises `"Out of order event"` (genuine
  mobbing still detected). Extends the saver `DccG02` concurrent-saves test.
- A stale range over legacy events (no id) behaves as today (dialog).
- Handoff: a refreshed browser at `head + 1` commits cleanly regardless of id.
