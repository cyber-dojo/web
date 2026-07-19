# Mobbing overlay diff-summary

Status: Proposed. Not built. This documents an agreed design only.

Pairs with `mobbing-stale-tab-lock.md`. That doc covers detecting staleness and
locking the tab. This doc covers one improvement to the locked-state experience:
showing the user what actually differs between their unsaved work and the version
they would resync to on refresh.

## What this does

When a tab locks because another laptop moved the committed head (the `laptop`
stale-kind, which raises the full-page `#mobbing-overlay`), the overlay today only
warns that a refresh "may lose recent edits to the current file". It shows nothing
about what those edits are or how they differ from the incoming version.

This adds a compact diff summary to that overlay: a per-file list of what differs
between the tab's current (uncommitted) editor buffer and saver's current head
(the version a refresh would adopt). For each differing file it shows the
filename, whether the file was created, deleted, renamed or changed, and the
added/deleted line counts. It does not show line-level content.

## Why

The lock protects the append-only log by stopping a behind tab from committing on
top of work it never saw. But it leaves the user blind: they are told they might
lose edits without being shown which files differ or by how much. A summary lets
them judge what is at stake and copy the right files out of the read-only editors
before they refresh.

Summary only (not a line-level diff) because the overlay needs just enough to
decide and act: names, the create/delete/rename/change kind, and a size cue. The
full side-by-side line diff is the review page's job, not the overlay's.

## The single diff

One diff between two file sets:

    differ.diff_summary(was_files: saver-current-head files,
                        now_files: this tab's editor buffer)

- `was` is saver's current head (what refresh will resync you to), so the incoming
  version reads as the baseline.
- `now` is your uncommitted buffer, so your unsaved edits read as the additions.

The choice of which set is `was` is only a display direction; this ordering makes
your own edits the added side.

## What diff_summary returns

differ's `diff_summary(was_files:, now_files:)` returns one entry per file, each
carrying exactly what the overlay needs and nothing heavier:

- `type` - `:created`, `:deleted`, `:renamed`, `:changed`, or `:unchanged`. This
  is the create/delete/rename signal directly.
- `old_filename` and `new_filename` - the names. Both are present on a rename, so
  the overlay can show `old -> new`.
- `line_counts` - `{added, deleted, same}`. This is the size cue. Note it is line
  counts, not byte sizes; differ does not emit bytes. Line counts are the same
  size signal the review page already shows.

`diff_summary` omits the per-line content (`diff_plus(..., lines: false)`), so the
payload stays small. The overlay lists only the changed/created/deleted/renamed
entries.

## Empty diff

The overlay can fire with no file differences at all. The lock is triggered by the
committed head moving, not by the buffer diverging from it: any commit from another
laptop advances the head and locks a behind tab, even when that commit changed no
files. For example the other user presses [test] with no new edits; the head
advances but its files match this tab's buffer exactly. `diff_summary` then returns
only `:unchanged` entries and the overlay has nothing to list.

The rendering must handle this case without showing an empty or broken file list.
It must not, however, promise that a refresh will lose nothing. Firing the lock
stops the poll loop, so the summary is frozen at the instant it fired (see the next
section) and the overlay learns nothing more about the head. By the time the user
refreshes, other laptops may have committed further and moved the head on, so a
refresh resyncs to whatever the head is then, which may no longer match this tab's
buffer. The wording should state only what is known at that instant: there were no
file differences to show.

## The summary is a snapshot, not live

The summary is computed once, at the moment the tab locks and the overlay is shown,
and it is never recomputed. The poll loop calls `stop()` as it locks (see
`cyber-dojo_mobbing_poll.js`), so no later tick refreshes the diff. Any wording in
the overlay must make clear it describes the difference *at that instant only*. This
matters most in the empty-diff case above: "no difference" is true when the overlay
opens, but other laptops can keep committing afterwards and the head can move
further, and the overlay will not reflect any of it. A refresh always resyncs to
whatever the head is at refresh time, which may differ from what the summary showed.

## How web serves it (server-side, contained in the web repo)

The diff call stays server-side in web. The browser cannot call differ directly:
differ's diff endpoints are registered as GET routes that read their `was_files`
and `now_files` from a JSON request body (a server-to-server shape), and a browser
`fetch` cannot put a body on a GET, nor fit two whole file-set maps in a query
string. There is also no nginx `/differ/` route. Between services this is a
non-issue, so web makes the call.

Flow:

1. Browser to web (new endpoint). The tab POSTs its current editor buffer (a
   `{filename => content}` map) to a new web route, for example
   `POST /kata/diff_uncommitted` with `{id, files}`. POST because the payload is
   whole files, not scalars. The buffer is collected the same way the existing
   `file_edit` / `[test]` write paths already collect it, reusing that source.

2. Web to saver. Web reads saver's current head files. It takes the head index
   from `saver.kata_events(id).last['index']` and the files from
   `saver.kata_event(id, head_index)['files']` (the same shape `source_event`
   already consumes in `app.rb`).

3. Web to differ. Web calls `differ.diff_summary(was_files: head_files,
   now_files: posted_buffer)` through a small web-side differ client that mirrors
   saver's server-side `External::Differ` (GET-with-body, which works fine between
   services).

4. Web to browser. Web returns the summary entries as JSON; the overlay renders
   the per-file list.

## What does not change

- saver: no new endpoint, no schema change. Web reads head files with the existing
  `kata_events` and `kata_event`.
- differ: no change. `diff_summary` already accepts two arbitrary file sets.
- nginx: no change. No `/differ/` route is added; the call is server-side in web.

So the whole feature is contained in the web repo: one new controller route plus a
small differ client class, and the overlay rendering.

## Code map (web)

- `app.rb` - the new `POST /kata/diff_uncommitted` route; reads saver head files
  via `kata_events` + `kata_event`; calls the new differ client.
- a new differ client service (mirroring saver's `External::Differ`) - posts
  `was_files` / `now_files` to differ's `diff_summary`.
- `assets/javascripts/cyber-dojo_mobbing_poll.js` - `showMobbingOverlay` collects
  the buffer, POSTs it, and renders the returned summary inside the overlay box.

## Out of scope

- Line-level diff content on the overlay (the review page covers that).
- Byte sizes (differ emits line counts only).
- Any change to the lock itself, the stale predicate, or the another-tab and
  generic app-bar messages. This only enriches the `laptop` overlay.
- Automatic merge or non-lossy refresh. Reconciling the buffer onto the new head
  is a manual merge; this design only shows the user what differs so they can do
  it by hand.
