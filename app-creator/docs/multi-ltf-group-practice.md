# Cross-repo plan: up to 5 LTFs per practice (Cluster + resolve-up design)

## Goal

A practice can offer **1-5 LTFs** (language-test-frameworks), and the same LTF may
appear more than once. Each child group has its **own** 0-63 avatar pool (up to
5 x 64 = 320 avatars). A joiner picks one LTF; the dashboard shows one **tab per
child group**, each a full 64-avatar grid. **Every existing group must keep working
unchanged.**

Spans `saver` (data model), `creator` (create/join/enter), `dashboard` (the
combined view) and `web` (the dashboard button on the edit/review pages).

> **Noun:** the multi-LTF umbrella is a **cluster** - a set of parallel groups
> (one per LTF) doing the same exercise. It sits one level above a group (a group
> is like a class of 64 avatars), well below a whole "school".

## Architecture: a Cluster over ordinary single-LTF groups

A `Group_v2` already *is* "one LTF + one exercise + one 0-63 avatar pool + one
roster" - exactly one LTF/tab. So a multi-LTF practice is a **cluster**: a new
top-level entity referencing **N (1-5) ordinary `Group_v2` children**, one per LTF.

- **Each child** is a normal `Group_v2` (one LTF + the shared exercise). The
  existing `group_*` create/join/joined/manifest work on a child **unchanged**.
- **A cluster is NOT a group.** It is a separate concept with its own endpoints,
  is **never joined directly**, and is **not** a `Group` version (the `GROUPS`
  version array is untouched - no `Group_v3`).
- **Single-LTF practice = a bare `Group_v2`** (today's path, no cluster). The
  cluster is created only for >1 LTF.

## Hierarchy + resolve-up contract

The system is a small hierarchy joined by **parent pointers**:

- `kata.group_id` -> its group (already exists).
- `group.cluster_id` -> its cluster, **only on a child group** (new field; bare
  groups omit it).

**The dashboard, given any id, walks UP to the topmost entity and renders that:**

- topmost is a **cluster** -> render one **tab per child group** (one per
  `group_id`, so duplicate-LTF children each get their own tab); each tab label
  specifies **both the LTF and the group-id** to tell same-LTF tabs apart.
- topmost is a **standalone `Group_v2`** -> render the single view (today).

Every entry point just passes the id it has and lets resolve-up do the rest:

- **web** dashboard button passes the **kata id**.
- **creator** "open dashboard" passes the **shared id** (a cluster id, or a bare
  group id).

Resolve-up is an explicit first step: you cannot hand a kata id straight to
`group_joined`, because saver's `group_joined` already resolves a *kata* to its
*(child)* group - which stops at the LTF group, not the cluster. So: resolve id ->
topmost; if a cluster, iterate its children calling the existing
`group_joined(child_id)` per tab; if a group, today's path. The walk can be a
small saver helper (e.g. `top_id(id)`) or done in the dashboard via existing
`kata_manifest`/`group_manifest` reads plus the new `cluster_id` field.

Back-compat is automatic: a bare group has no `cluster_id`, so its topmost is
itself -> today's single view; existing katas resolve kata -> group -> (no
cluster) -> the group dashboard, unchanged.

## Data model

**Cluster manifest** (stored separately, e.g. `/cyber-dojo/clusters/<id>/manifest.json`):

```jsonc
{
  "id": "...",
  "created": [...],
  "exercise": "Tennis",            // group-wide
  "children": [                    // 1..5
    { "ltf_display_name": "Python, unittest", "group_id": "<child id>" },
    { "ltf_display_name": "Ruby, MiniTest",   "group_id": "<child id>" }
  ]
}
```

- **Child group manifest** - an ordinary `Group_v2` manifest + a `cluster_id`
  parent pointer.
- **Kata manifest** - unchanged (`group_id` is the child's id). The kata does
  **not** carry `cluster_id`; the dashboard reaches the cluster via
  `kata.group_id -> group.cluster_id`.

## Behavioural map (who must become cluster-aware)

Consumers that take the participant-shared id (or walk the hierarchy):

- **creator `id_typer.rb:8`** (`id_type`) - classify **cluster | group | kata**
  (currently only group/kata).
- **creator `app.rb:91`** (`enter.json` -> `group_join`) - for a cluster, resolve
  cluster + chosen LTF -> child id -> existing `group_join(child)`.
- **creator `app.rb:128`** (`reenter` -> `group_joined`) - for a cluster, resolve
  -> children -> per-child grids.
- **dashboard `manifest.erb:10`, `avatars_progress.rb:8,23`, `gatherer.rb:13,30`**
  (`group_manifest`/`group_joined` on the given id) - resolve up, then render a
  cluster as tabs (existing per-group rendering per child) or a group as today.
- **web `_dashboard.erb:16`** - the dashboard button passes the **kata id**
  (`/dashboard/show/${manifest.id}`, was `manifest.group_id`); resolve-up opens
  the cluster. No `cluster_id` on the kata, no cluster knowledge in web. Keep the
  existing guard (button only shows when the kata is in a group).

Not affected:

- **web review/edit + avatar navigator/selector** (`group_joined({id:review.id})`)
  - `review.id` is a kata id; saver resolves it to the kata's *(child)* group, so
  navigation stays within the same LTF. (See open question.)
- **saver `group_*` methods** - unchanged, still group/kata-scoped.

## Repo work

### saver
- New **cluster** entity: `cluster_create` (input: `exercise` + the per-LTF child
  manifests) and `cluster_manifest` (read) endpoints + a small model class + its
  own storage. Optional `top_id(id)` helper for resolve-up.
- **`cluster_create` materializes the children itself** (Option B): it generates
  the cluster id, then for each LTF manifest creates an ordinary `Group_v2` child
  carrying `cluster_id` (the parent pointer), and stores the cluster referencing
  them as `children: [{ ltf_display_name, group_id }]`. Groups stay write-once (no
  back-stamping), and `cluster_id` is consistent from birth. `group_*` is
  otherwise unchanged; no `Group_v3`; `GROUPS`/`CURRENT_VERSION` untouched.

### creator
- Prerequisite: the **kind-first reorder** (kind -> exercise -> LTF).
- **Create:** pick exercise, then 1-5 LTFs (group only). `POST /create.json`
  dispatches on `type` (`app.rb` `create`): **`type: 'group'`** + `language_name`
  -> `group_create` (today's bare `Group_v2`, unchanged single-LTF path);
  **`type: 'cluster'`** + `language_names` ([String...], 2-5) -> `cluster_create`,
  which builds a per-LTF manifest list (`Creator#cluster_create`) and makes one
  `saver.cluster_create` call that creates the child groups + the cluster and
  returns the cluster's 6-digit id. The UX sends `type: 'group'` for one LTF and
  `type: 'cluster'` for 2-5. `group_create` keeps its original
  `(language_name:, exercise_name:)` signature (untouched). New code: creator
  `cluster_create` (the `app.rb` dispatch arm + `Creator#cluster_create` +
  `ExternalSaver#cluster_create`) and the saver's `cluster_create` /
  `cluster_manifest`. Display names contain commas, so `language_names` is a JSON
  array, never a delimited string.
- **Join:** enter id -> `id_type`; for a cluster, fetch `cluster_manifest`, show an
  LTF picker of the **distinct** `children[].ltf_display_name` values - duplicates
  collapse to one entry, so a cluster with 3x `Java, JUnit` shows `Java, JUnit`
  once. The joiner picks a display name; resolving that name to a specific child id
  (when several children share it) and the rest of the join implementation are **to
  be specified later**. It then calls the existing `group_join(child)`. Bare group /
  kata: today's flow.
- **reenter:** per-child grids.

### dashboard
- Resolve the given id up to the topmost entity; **cluster -> one tab per child
  group** (per `group_id`, so duplicate-LTF children each get their own tab; each
  tab the existing single-group rendering of a child); **group -> single view**
  (today).
- **Tab labels** specify both the **LTF** and the **group-id**, so several
  `Java, JUnit` tabs are distinguishable.

### web
- `_dashboard.erb`: pass the kata id to `/dashboard/show`. Nothing else.

## Testing

- **saver:** `cluster_create` stores + round-trips `exercise` + `children` (real
  `Group_v2` children with distinct LTFs and `cluster_id`); a cluster is **not**
  joinable; resolve-up / `top_id` maps kata -> group -> cluster; **`group_*`
  regression** (bare groups unchanged).
- **creator:** create children + cluster; enter a cluster -> pick LTF -> join
  resolves to the child id via existing `group_join`; bare group / kata join
  directly; `reenter` per child.
- **dashboard:** resolve-up renders a cluster as tabs and a standalone group as a
  single view identical to today.
- **web:** the dashboard button opens the topmost (cluster) by passing the kata id.

## Already done (keep)

- **Bug B fix** (`capture_stdout_stderr` no longer swaps the global
  `$stdout`/`$stderr`; test `Cs7f01`) - independent of this design.

## Design goals

- **Distinct avatars across a cluster's groups.** Each child group has its own
  0-63 avatar pool, so allocating each group independently could hand out the
  same low indices in every group - eg a 4-LTF cluster with two joiners per
  group where all four groups show the same two animals (bear + salmon). That is
  needlessly confusing: the same animal would appear in several tabs as
  different people. Avatar allocation for a cluster should spread avatars so a
  given animal identifies one person across the whole cluster, as far as
  possible. (Only 64 animals exist, so full cluster-wide distinctness is only
  achievable while the cluster has <= 64 joiners in total; beyond that, reuse is
  unavoidable and should degrade gracefully.)

  Mechanism: no `Group_v2#join` change is needed - `group_join(id:, indexes:)`
  already accepts an `indexes` candidate-order argument (defaulted to a shuffled
  `0..63`, and currently undocumented in the saver's `docs/api.md`). `join`
  allocates the first still-free index in that order (the joined group's own
  taken indexes are removed first). So a cluster-aware join passes an `indexes`
  order listing avatars not yet used anywhere in the cluster first - preferring a
  cluster-distinct avatar while any remain, degrading to reuse past 64. To do
  this the join flow must know the cluster's sibling groups (via the cluster
  manifest's `children`) and union their used indexes. The `indexes` parameter
  should be publicised in `docs/api.md`.

## Decided

- **Single-LTF = bare `Group_v2`** (today's path); the cluster exists only for
  >1 LTF, leaving the single-LTF flow untouched.
- **Transport / dispatch:** `POST /create.json` dispatches on `type`:
  `type: 'group'` + `language_name` -> `group_create` (bare group, today's path,
  signature unchanged); `type: 'cluster'` + `language_names` ([String...], 2-5) ->
  `cluster_create` -> `saver.cluster_create`; otherwise kata. The UX sends
  `type: 'group'` for one LTF and `type: 'cluster'` for 2-5. The single-LTF path is
  untouched, so existing trainer scripts keep working. New code: creator
  `cluster_create` and the saver's `cluster_create` / `cluster_manifest`. Display
  names contain commas, so `language_names` is a JSON array, never a delimited
  string.
- **A cluster is a separate top-level entity** (not a group, not a group version);
  `group_*` and the `GROUPS` array are untouched.
- **Hierarchy via parent pointers** (`kata.group_id`, `group.cluster_id`); the
  dashboard **resolves any id up to the topmost** and renders it.
- **web's dashboard button passes the kata id**; the kata gains no `cluster_id`.
- **Noun = `cluster`** - a set of parallel groups (one per LTF) doing the same
  exercise; one level above a group.
- **Join picker shows DISTINCT LTFs** - duplicate children in a cluster collapse to
  one entry, so a cluster with 3x `Java, JUnit` shows `Java, JUnit` once. (Which
  duplicate child a joiner lands in is deferred - see Open decisions.)
- **Dashboard shows one tab per child group-id** (NOT deduped, unlike the join
  picker) - 3x `Java, JUnit` => 3 tabs. Each tab label specifies **both the LTF and
  the group-id** so the same-LTF tabs are distinguishable.

## Open decisions

1. **web avatar navigator/selector** - keep per-LTF (child group, today) or make
   it cluster-wide.
2. **Exercise scope** - group-wide (one exercise across all LTFs; each child group
   carries the same exercise). Confirm intended.
3. **Empty tabs** - show all offered LTFs, or only those with >= 1 avatar.
4. **Cluster storage / id space** - own dir (e.g. `clusters/`), ids from the shared
   `IdGenerator` so cluster/group/kata ids never clash.
5. **Duplicate-child selection on join** - the join picker shows duplicates as a
   single entry (see Decided), so when a cluster has several children sharing one
   `ltf_display_name` (e.g. 3x `Java, JUnit`), **which** of them a joiner is placed
   into - and the join implementation generally - is **to be specified later**.
   (The dashboard already handles duplicates: one tab per child group-id - see
   Decided.)
