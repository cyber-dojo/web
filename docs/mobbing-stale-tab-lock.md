# Mobbing stale-tab lock (spooler ADR step A1)

Status: Partially implemented (web), not deployed. See "Implementation status
(handoff)" at the end for what is done and what remains.

Precondition A0 is deployed: each committed event carries the writing browser's
`laptop_id`. This is a web-only step of the spooler rollout
(`spooler/docs/adr-async-writes-via-spooler.md`); saver is unchanged.

## What this does

A browser tab editing a kata polls the committed event stream and locks itself
when it has fallen behind the committed head. A stale tab disables everything
that would commit an event (the `[test]` button, the code editor, the file
create/rename/delete actions, and checkout/revert), and shows a banner asking the
user to refresh. Refreshing is the only exit: a reload adopts the current head,
so the tab is no longer behind and unlocks.

## Why

Two reasons that point the same way:

1. Web is moving to asynchronous saver writes that carry no index
   (`mobbing-server-owned-index-design.md`). Saver assigns the index and simply
   appends, so it does not reject an out-of-date write. The only place left to
   notice that a tab is behind is the browser itself.

2. A tab that writes while behind the head silently diverges: its event is
   appended on top of newer work it never saw, moving the head to a stale file
   state with no signal to anyone. Locking a behind tab before it can write
   prevents that divergence.

Detecting "am I behind?" rather than "is another laptop here?" is the property
that covers both a second laptop and a second tab of the same browser. The
second-tab case is the one that would otherwise diverge with no warning.

## The state each tab holds

- `knownHead` - the index of the last event this tab had incorporated when it
  loaded. Fixed for the tab's life; only a reload resets it (to the new load
  head). It never advances while the tab is open - the `tab_id` filter below is
  what lets it stay fixed.
- `myTabId` - this tab's `tab_id` (see below), also fixed for the tab's life.

## The predicate

> The tab is stale (and locks) iff some committed event above `knownHead` was
> written by a different tab than mine (its `tab_id` differs from `myTabId`).

Two filters, both needed. `knownHead` excludes the history I loaded (events at or
below it were already incorporated at load, whoever wrote them - so a prior
laptop's events in a handoff never lock me). `tab_id` excludes my own later
writes (an event above `knownHead` carrying my `tab_id` is mine, so it never
locks me). What is left - an event above `knownHead` from another tab or laptop -
is the only thing that locks. This is why `knownHead` stays fixed: my own writes
are filtered by `tab_id`, not by moving `knownHead`.

### Wording the banner

The lock is the same however the head moved; only the banner text differs. The
tab classifies the events above `knownHead` by `laptop_id`:

- any has a `laptop_id` different from mine -> "This kata was changed on another
  laptop. Refresh to continue."
- all carry my own `laptop_id` -> "This kata was changed in another tab. Refresh
  to continue."
- otherwise (an event with no `laptop_id`; a legacy or malformed write) -> a
  generic "This kata changed. Refresh to continue."

## Recognising this tab's own writes (tab_id)

In the fully asynchronous end-state the write response cannot say where (or
whether) this tab's write landed - the commit happens later - so the tab learns
its write committed only by seeing it in the poll. And `laptop_id` alone cannot
pick out this tab's own write: a second tab of the same browser shares the
`laptop_id`, so "the new event carries my `laptop_id`" is ambiguous between my
own write and my other tab's write.

So each tab has a `tab_id`: a freshly random id the browser generates once per
tab and holds for the tab's lifetime. Every write the tab makes carries its
`tab_id`, saver stores it on the committed event, and the predicate filters by
it:

- an event above `knownHead` bearing my `tab_id` -> my own write -> filtered out,
  does not lock me.
- an event above `knownHead` not bearing my `tab_id` (another tab, another
  laptop) -> not mine -> I am behind -> lock.

Filtering my own writes out (rather than moving `knownHead` past them) dissolves
the in-flight window: a write I have fired but whose response I have not yet
processed still carries my `tab_id`, so when the poll sees it committed it is
filtered and never locks me. No pending-write count, no `knownHead` advancement,
no timing race.

`tab_id` must be freshly random per tab. That is what the poll trusts: two tabs
of one browser get different `tab_id`s (so a second tab reads as another writer),
and no live `tab_id` collides with another tab's or with a stored id's second
half (below).

### Transport: laptop_id + tab_id in one stored id, no saver change

`tab_id` needs no new saver field. The browser concatenates a 32-hex `laptop_id`
and a 32-hex `tab_id` into one 64-hex string and sends it as the write's id;
saver stores the string verbatim on the event, exactly as it already stores
`laptop_id`. On read the tab splits every id at 32 characters: the first half is
the `laptop_id` (banner wording), the second half is the `tab_id` (own-write
recognition). Saver needs no schema or API change.

(`laptop_id` is already in the saver code but not yet in the saver API docs; this
piggybacks on that same stored field.)

### Old plain ids are safe under the unconditional split

Events committed before this scheme carry a plain 64-hex `laptop_id` and no
`tab_id`. The split stays unconditional - there is no "old vs new" detection: a
plain id splits into a first half (its `laptop_id`) and a second half taken as a
`tab_id`. That synthetic second half is inert precisely because a live `tab_id`
is freshly random: it can never equal a plain id's fixed second half (collision
~2^-128), so an old event is always read as "not this tab's". The error is in the
safe direction - an old event above `knownHead` (only if an un-upgraded browser
writes concurrently during rollout) counts as another writer and locks; a
historical old event below `knownHead` is excluded by the `knownHead` floor.

### The +2 write is handled automatically

`ran_tests` threads the single id it receives through both the internal
`file_edit` it inserts and the test event (saver `kata_v2.rb`: `ran_tests` ->
`file_edit_before_test_event` -> `file_edit` for the first, `git_commit_tag_sss`
for the second, all passed the same id), so both committed events carry the same
`tab_id` and both are filtered as mine - neither locks me, with no special
handling. (The internal `file_edit` commits only when a file was actually edited,
and can be dropped on a concurrent same-laptop CAS-loss, so a write commits one
event or two; either way every committed event of that write carries this tab's
`tab_id`.)

### Per-write identity and lost writes (out of scope)

`tab_id` tells the lock whether an event is this tab's - all the lock needs - so
it holds no per-write token and has no token-lifetime concern. Telling one of my
writes from the next (which specific write landed) needs per-write identity,
`(tab_id, client_seq)`, where `client_seq` is the spooler's per-tab counter
(`spooler/docs/adr-async-writes-via-spooler.md`).

What the tab observes still separates the failure modes, if a diagnosis is built
later: reads failing means the read side is unreachable (the poll fail-safe
covers it, do not lock); the head not moving while an expected own write never
appears means the write path dropped it (a lost write, distinct from staleness);
the head moving with events that are not mine means I am behind (the lock fires).
Acting on a lost write - retrying, deciding committed-or-not-yet - pulls in
idempotency and is a separate follow-on, not built here.

## Poll behaviour

- Cadence: every 5 seconds (the ADR eventual-consistency budget).
- Ids: the `laptop_id` comes from a `<meta name="laptop-id">` tag rendered by web
  (drives banner wording and the laptop half of the stored id); the `tab_id` is
  generated fresh in JS once per tab (it must be per-tab, so it cannot be a cookie
  or meta tag) and is this tab's `myTabId`.
- Fail safe: if a poll read errors or returns nothing (saver blip, network drop,
  5xx), skip that tick and keep polling. Never lock on a failed or empty read; a
  missed read only delays detection by one interval.
- Load: confirm nginx does not rate-limit `/saver/kata_events` (a 429 would look
  like a failed read), and back off while the tab is hidden (`document.hidden`).
  A hidden tab stays quiet and evaluates (and, if stale, locks) when the user
  brings it to the foreground.
- Lifecycle: stop the poll on page unload / navigation so no interval leaks.
- No suspend during review: review is read-only navigation of past states, so a
  stale tab does no harm there, and the lock is in effect the moment the user
  returns to editing. The poll runs continuously on the edit page.

## Use cases

Each tab loaded when the committed stream held the create event plus two `[test]`
events (indices 0..2), so `knownHead = 2` at load. `L1` and `L2` are two
`laptop_id`s.

### 1. Another laptop commits

`knownHead = 2` for every tab. Laptop L2 commits E3.

| this tab | event above knownHead | mine? | stale? |
|---|---|---|---|
| any, before E3 | none | - | no |
| L1 | E3 (L2's tab_id) | no | yes -> lock, "another laptop" |
| L2 (the writer) | E3 (its own tab_id) | yes | no |

L2 is not stale because E3 carries its own `tab_id` and is filtered out, not
because `knownHead` moved.

### 2. Handoff (a solo user switches laptop)

The second browser loads the already-worked kata, so `knownHead = 2` covers
E1..E2 - below the floor, they never lock it, whoever wrote them. Its own later
E3 carries its `tab_id`, so it is filtered out and the tab stays unlocked.

### 3. Two tabs of one browser

Tab A and tab B share a `laptop_id` but each has its own `tab_id`. Tab A commits
E3; `knownHead = 2` for tab B.

| tab B sees | event above knownHead | mine (tab B's tab_id)? | stale? |
|---|---|---|---|
| before E3 | none | - | no |
| after E3 | E3 (tab A's tab_id) | no | yes -> lock, "changed in another tab" |

The shared `laptop_id` does not make E3 mine - `tab_id` does, and tab A's differs.
A tab open only to read the instructions is not editing or testing, so the lock
is invisible to it. If the user does try to write in tab B, the lock blocks the
stale write - the divergence we want to prevent.

### 4. Both tabs / laptops writing

Each tab sees the other's events above its `knownHead` carrying a different
`tab_id` (not mine), so each locks; each tab's own writes carry its own `tab_id`
and are filtered. So each is locked by the other's writes, never its own.

This mutual lock is intended, not a deadlock. A refresh clears it - reloading
resets `knownHead` to the current head, putting both events below the floor. In a
healthy mob (one driver at a time) only the follower locks; the "both locked"
state arises only under near-simultaneous writes, and can thrash if both keep
writing without refreshing. That is the tool forcing two competing writers to
coordinate (one drives, the other reads and refreshes) rather than silently
diverge on the append-only log.

### 5. Any event type

Detection is on whether an event above `knownHead` is another tab's, not on
colour, so another writer's file edit locks the tab just as a `[test]` would.

## What does not change

saver: no new endpoint, no schema change. `/saver/kata_events` already exists and
already returns `laptop_id` per event. This is a web-only change.

## Code map (web)

- `assets/javascripts/` - the poll loop, the stale predicate (`isStale(events,
  knownHead, myTabId)`), the stored-id split, `tab_id` generation, and the
  banner-wording classifier.
- `views/kata/edit.erb` - starts the poll, seeds `knownHead` from the loaded
  events, and generates this tab's `tab_id`.
- `views/kata/_run_tests.erb` and the inter-test / review actions - gate every
  event-committing action behind the lock; send `laptop_id + tab_id` as the write
  id; remove the write-time out-of-sync dialog path, since detection is entirely
  this poll. Add the refresh banner.
- `app.rb` - the `laptop-id` meta tag.

## Tests

- Unit: the stale predicate over a committed stream and a `knownHead`, one test
  per use case above.
- Behavioural: a tab locks when another writer advances the head; a tab does not
  lock on its own committed writes; the `[test]` button and editor are disabled
  while locked and a refresh clears the lock; a failed or empty read locks
  nothing and the poll keeps polling; the poll stops on unload.

## Implementation status (handoff)

The web side is largely built and the poll is wired up (`edit.erb` auto-starts it
on page load), but nothing here is deployed. Styling and two clean-up phases
remain.

### Done
- Predicate `cd.isStale(events, knownHead, myTabId)` and the poll/lock in
  `assets/javascripts/cyber-dojo_mobbing_poll.js` (`cd.mobbingPoll`: `tabId`,
  `knownHead`, `intervalMs`, `locked`, `polling`, `enable(id)`; plus `lock`,
  `showBanner`, `bannerMessage`, `tabIdOf`, `laptopIdOf`, `myLaptopId`,
  `generateTabId`).
- Poll auto-started: `views/kata/edit.erb` seeds `knownHead` and calls
  `cd.mobbingPoll.enable("<%= @id %>")`.
- On lock: disable `[test]`, editors read-only, disable the
  file-create/rename/delete and checkout/revert/fork buttons, guard the commit
  paths (`cd.kata.runTests` and `cd.revertOrCheckout` bail when locked), keep the
  review buttons disabled via their `refresh` guards, show the banner.
- Writes stamp `tab_id`: every event-committing POST sends it (`_run_tests.erb`
  `[test]` + auto-`revert`, `_file_inter_test_events.erb`
  `syncPostWithCallbackITE`, `_checkout_button.erb` `revertOrCheckout`);
  `app.rb`'s `laptop_id` returns `cookie[0,32] + tab_id` (fallback: full cookie).
- `<meta name="laptop-id">` in `views/layouts/application.erb`; banner wording
  "another laptop" vs "another tab" derived from it.
- `runTests` fires its POST immediately (no longer gated on the wait-spinner
  fade-in, which paused in a backgrounded tab).
- Tests: `source/test/app_browser/mobbing_test.rb`, `m0b001`-`m0b019` (predicate
  use cases 1-5; poll state; lock/disable/banner; write `tab_id`-stamping;
  auto-start; meta tag; banner wording). Run with `make test_browser`.
- Test infra: browser tests run through nginx (`bin/containers_up.sh`,
  `browser_test_base.rb` -> `http://nginx`); `make test_browser` +
  `bin/run_browser_tests.sh`; `bin/run_tests_in_container.sh` helpers extracted.
- CSS: disabled buttons use `cursor: not-allowed` consistently (`button.scss`).

### Settled decisions (do not relitigate)
- `laptop_id` stays a per-browser shared cookie; two tabs share it. `tab_id`
  distinguishes tabs and is freshly random per tab (never a cookie).
- Stored id = `laptopHalf(32) + tabId(32)`, `laptopHalf = cookie[0,32]`. Old
  plain 64-hex ids are safe (their synthetic second half never matches a live
  random `tab_id`).
- `knownHead` is the fixed load head; own writes are filtered by `tab_id`, so it
  never advances (this also dissolves the in-flight-write window).
- All write paths must carry `tab_id` before the poll is enabled (they do).

### Remaining (priority order)
1. BANNER STYLING - where this session stopped. `#mobbing-banner` is an unstyled
   `<div>` appended to `<body>`; its location and appearance are bad. Needs a
   real SCSS design, likely a Refresh button that `location.reload()`s, and
   possibly an overlay element. PAUSED decision on the form: modal overlay
   (recommended - dims page, centered box, matches the full lock), fixed top bar,
   or corner toast. Match the dark theme. The "too dark" disabled-button colours
   belong in this same styling pass.
2. PHASE 5 - poll robustness:
   - fail-safe: a failed/empty/erroring read must never lock (`getEvents` has no
     `.catch`; also `tabIdOf` throws on an event with no `laptop_id` above
     `knownHead` - guard it);
   - `document.hidden` back-off: skip/pause polling while the tab is hidden,
     evaluate on foreground;
   - stop the poll on page unload (store the interval handle - currently local in
     `enable`), and fold in the deferred `enable` "clear any previous interval"
     so re-enabling restarts a single timer.
3. PHASE 6 - remove the old write-time catch (`_run_tests.erb`
   `showAvatarsOutOfSync` / the `if (outOfSync)` path). IT STILL FIRES: a stale
   `[test]` currently triggers BOTH the old dialog and the poll lock. Removing it
   makes the poll the sole detector.
4. Generic / no-id banner + `isStale` no-id hardening: an event with no
   `laptop_id` above `knownHead` (legacy / un-upgraded writer) throws in
   `tabIdOf`. Guard it, treat as "not mine" (safe), add the generic "This kata
   changed. Refresh to continue." wording (old use case 7).

### Manually verified this session
- Two-tab lock (a write in one tab locks the other): yes.
- Locked tab: Alt-T / predict hotkeys do nothing; review revert/checkout/fork
  disabled: yes.
- `[test]`, file-event and auto-revert writes carry `laptopHalf + tabId` (checked
  committed `events.json` for kata `XM2NHU`): yes.
