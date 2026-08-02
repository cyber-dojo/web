require_relative 'browser_test_base'
require 'json'

# Tests of the mobbing stale-tab detection (docs/mobbing-stale-tab-lock.md),
# driven in a real browser. m0b001..m0b005 are the predicate use cases: they load
# a kata edit page (so app.js defines cd.isStale) and drive
# cd.isStale(events, knownHead, myTabId) - true iff some event above knownHead was
# not written by this tab (its tab_id differs from mine) - with a hand-built
# committed stream; in those the tab loaded at head 2, so knownHead = 2.
# m0b006.. cover the poll/lock layer (cd.mobbingPoll) that drives the predicate.
class MobbingTest < BrowserTestBase

  test 'm0b001', %w(
  | use case 1, the core case: loaded at head 2. An event above my knownHead that
  | is not mine (another laptop) makes me stale; an event above my knownHead that
  | IS mine (my own write, my tab_id) does not - my own writes never lock me.
  | "mine" is decided by tab_id.
  ) do
    open_a_kata_edit_page

    laptop = 'a1' * 16
    my_tab = 'b2' * 16
    mine   = stored_id(laptop, my_tab)
    other  = stored_id('c3' * 16, 'd4' * 16)   # another laptop
    known_head = 2
    stream = [
      { 'index' => 0 },                                        # E0-? create
      { 'index' => 1, 'laptop_id' => mine, 'colour' => 'red'   }, # E1
      { 'index' => 2, 'laptop_id' => mine, 'colour' => 'amber' }, # E2
    ]

    # Nothing above knownHead: not stale.
    refute is_stale(stream, known_head, my_tab), 'not stale when nothing is above knownHead'

    # Another laptop commits above knownHead: not mine, so stale.
    other_event = { 'index' => 3, 'laptop_id' => other, 'colour' => 'green' }
    assert is_stale(stream + [other_event], known_head, my_tab),
      'stale when another laptop commits above knownHead'

    # My own write above knownHead: mine, so not stale.
    my_event = { 'index' => 3, 'laptop_id' => mine, 'colour' => 'green' }
    refute is_stale(stream + [my_event], known_head, my_tab),
      'not stale when the event above knownHead is my own'
  end

  test 'm0b002', %w(
  | use case 2 (handoff): a solo user opens the already-worked kata on a second
  | browser. The earlier browser's events are below this browser's knownHead, so
  | they do not lock it (it incorporated them at load), even though they carry a
  | different id. Its own later write is mine, so it stays not stale.
  ) do
    open_a_kata_edit_page

    prior  = stored_id('c3' * 16, 'd4' * 16)   # the earlier browser
    my_tab = 'b2' * 16
    mine   = stored_id('a1' * 16, my_tab)      # this (second) browser
    known_head = 2
    stream = [
      { 'index' => 0 },                                            # E0-? create
      { 'index' => 1, 'laptop_id' => prior, 'colour' => 'red'   }, # E1, earlier browser
      { 'index' => 2, 'laptop_id' => prior, 'colour' => 'amber' }, # E2, earlier browser
    ]

    # The earlier browser's events are below my knownHead: not stale.
    refute is_stale(stream, known_head, my_tab), 'not stale: prior events are below knownHead'

    # My own first write above knownHead is mine, so still not stale.
    stream << { 'index' => 3, 'laptop_id' => mine, 'colour' => 'green' } # E3, this browser
    refute is_stale(stream, known_head, my_tab), 'not stale: my own write does not lock me'
  end

  test 'm0b003', %w(
  | use case 3 (two tabs of one browser): tab B shares tab A's laptop_id half but
  | has its own tab_id half. When tab A commits above tab B's knownHead, tab B is
  | stale even though the laptop_id half matches - "mine" is decided by tab_id,
  | not laptop_id, so a second tab of the same browser is another writer.
  ) do
    open_a_kata_edit_page

    laptop = 'a1' * 16   # shared by both tabs (same browser cookie)
    tab_a  = 'b2' * 16
    tab_b  = 'e5' * 16   # this tab
    known_head = 2
    stream = [
      { 'index' => 0 },                                                    # E0-? create
      { 'index' => 1, 'laptop_id' => stored_id(laptop, tab_b), 'colour' => 'red'   }, # E1
      { 'index' => 2, 'laptop_id' => stored_id(laptop, tab_b), 'colour' => 'amber' }, # E2
    ]

    # Tab A (same laptop, different tab) commits above my knownHead.
    tab_a_event = { 'index' => 3, 'laptop_id' => stored_id(laptop, tab_a), 'colour' => 'green' }
    assert is_stale(stream + [tab_a_event], known_head, tab_b),
      'stale: another tab of my browser is not mine (same laptop_id, different tab_id)'
  end

  test 'm0b004', %w(
  | use case 4 (two live laptops both writing): L1 commits E3 and L2 commits E4,
  | both above the shared knownHead. Each is stale because it sees the other's
  | event (a different tab_id) above knownHead - even though its own write is also
  | there, filtered as mine. Each is locked by the other's write, never its own.
  ) do
    open_a_kata_edit_page

    l1_tab = 'b2' * 16
    l2_tab = 'e5' * 16
    l1 = stored_id('a1' * 16, l1_tab)
    l2 = stored_id('c3' * 16, l2_tab)
    known_head = 2
    stream = [
      { 'index' => 0 },                                         # E0-? create
      { 'index' => 1, 'laptop_id' => l1, 'colour' => 'red'   }, # E1
      { 'index' => 2, 'laptop_id' => l1, 'colour' => 'amber' }, # E2
      { 'index' => 3, 'laptop_id' => l1, 'colour' => 'green' }, # E3, L1 writes
      { 'index' => 4, 'laptop_id' => l2, 'colour' => 'green' }, # E4, L2 writes
    ]

    # L1 sees L2's E4 above knownHead (not L1's tab), so it is stale, even though
    # its own E3 is also above knownHead (filtered as mine).
    assert is_stale(stream, known_head, l1_tab), 'L1 is stale: L2 event E4 above knownHead is not mine'

    # L2 sees L1's E3 above knownHead (not L2's tab), so it is stale, even though
    # its own E4 is also above knownHead (filtered as mine).
    assert is_stale(stream, known_head, l2_tab), 'L2 is stale: L1 event E3 above knownHead is not mine'
  end

  test 'm0b005', %w(
  | use case 5 (any event type): detection is on tab_id and index, not on colour,
  | so another tab's file edit above knownHead locks me just as a [test] would.
  ) do
    open_a_kata_edit_page

    my_tab = 'b2' * 16
    mine   = stored_id('a1' * 16, my_tab)
    other  = stored_id('c3' * 16, 'd4' * 16)   # another laptop
    known_head = 2
    stream = [
      { 'index' => 0 },                                        # E0-? create
      { 'index' => 1, 'laptop_id' => mine, 'colour' => 'red'   }, # E1
      { 'index' => 2, 'laptop_id' => mine, 'colour' => 'amber' }, # E2
    ]

    # Another tab commits a file edit (not a [test]) above my knownHead.
    file_edit = { 'index' => 3, 'laptop_id' => other, 'colour' => 'file_edit', 'filename' => 'hiker.sh' }
    assert is_stale(stream + [file_edit], known_head, my_tab),
      'stale: another tab file edit locks just like a [test]'
  end

  test 'm0b006', %w(
  | poll state: on load the tab has a freshly generated 32-hex tab_id, stable
  | within the tab, and cd.mobbingPoll.knownHead is seeded to the loaded committed
  | head. A freshly created kata has only the index-0 event, so knownHead is 0.
  ) do
    open_a_kata_edit_page

    tab_id = evaluate_script('cd.mobbingPoll.tabId')
    assert_match(/\A[0-9a-f]{32}\z/, tab_id, 'tab_id is 32 hex chars')
    assert_equal tab_id, evaluate_script('cd.mobbingPoll.tabId'),
      'tab_id is stable within the tab'

    assert_equal 0, evaluate_script('cd.mobbingPoll.knownHead'),
      'knownHead is seeded to the loaded head (0 for a fresh kata)'
  end

  test 'm0b007', %w(
  | poll locks on another tab's event: once enabled, the poll reads the committed
  | stream and, seeing an event above knownHead written by another tab (a tab_id
  | different from mine), locks the tab (adds body.mobbing-stale).
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
  end

  test 'm0b008', %w(
  | poll does not lock on my own event: an event above knownHead carrying THIS
  | tab's tab_id is mine, so the enabled poll leaves the tab unlocked.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    my_tab = evaluate_script('cd.mobbingPoll.tabId')
    files = saver.kata_event(id, 0)['files']
    mine = stored_id('a1' * 16, my_tab)
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), mine, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    sleep 1   # several poll intervals; a wrongly-locking poll would have fired by now
    refute_selector 'body.mobbing-stale'
  end

  test 'm0b009', %w(
  | locking disables the [test] button: after the poll locks on another tab's
  | event, the [test] button is disabled so the stale tab cannot commit a test.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '#test-button[disabled]'   # enabled on a fresh, in-sync kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector '#test-button[disabled]', wait: 5
  end

  test 'm0b010', %w(
  | locking makes the editor read-only: after the poll locks on another tab's
  | event, every CodeMirror editor is read-only so the stale tab cannot edit.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute all_editors_read_only?, 'at least one file is editable on a fresh, in-sync kata'

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert all_editors_read_only?, 'every editor is read-only after lock'
  end

  test 'm0b011', %w(
  | locking disables the file create/rename/delete buttons: after the poll locks
  | on another tab's event, those buttons are disabled so the stale tab cannot
  | commit a file event.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '.create-file[disabled]'   # enabled on a fresh, in-sync kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector '.create-file[disabled]'
    assert_selector '.delete-file[disabled]'
    assert_selector '.rename-file[disabled]'
  end

  test 'm0b020', %w(
  | locking disables the predict checkbox: after the poll locks on another tab's
  | event, the predict checkbox is disabled so the stale tab cannot start a
  | prediction.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '#predict-checkbox[disabled]', visible: :all   # enabled on a fresh kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector '#predict-checkbox[disabled]', visible: :all
  end

  test 'm0b021', %w(
  | locking disables the predict colour buttons: after the poll locks on another
  | tab's event, the red/amber/green predict buttons are disabled so the stale tab
  | cannot commit a prediction run.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector 'button.predict[disabled]', visible: :all   # enabled on a fresh kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector 'button.predict[disabled]', visible: :all, count: 3
  end

  test 'm0b022', %w(
  | locking disables the auto-revert checkboxes: after the poll locks on another
  | tab's event, the three revert-if-wrong checkboxes are disabled so the stale
  | tab cannot arm an auto-revert.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '.revert-checkbox[disabled]', visible: :all   # enabled on a fresh kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector '.revert-checkbox[disabled]', visible: :all, count: 3
  end

  test 'm0b023', %w(
  | locking suppresses the predict-checkbox tooltip: after the poll locks, entering
  | the predict-checkbox cell shows no hover-tip (its handlers are unbound).
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("jQuery('#predict-checkbox-cell').mouseenter()")   # tip shows before lock
    assert_selector '.hover-tip', visible: :all
    execute_script("jQuery('#predict-checkbox-cell').mouseleave()")

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")
    assert_selector 'body.mobbing-stale', wait: 5

    execute_script("jQuery('#predict-checkbox-cell').mouseenter()")
    refute_selector '.hover-tip', visible: :all
  end

  test 'm0b024', %w(
  | locking suppresses the auto-revert title tooltip: after the poll locks,
  | entering the revert-title cell shows no hover-tip (its handlers are unbound).
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("jQuery('#revert-title-cell').mouseenter()")   # tip shows before lock
    assert_selector '.hover-tip', visible: :all
    execute_script("jQuery('#revert-title-cell').mouseleave()")

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")
    assert_selector 'body.mobbing-stale', wait: 5

    execute_script("jQuery('#revert-title-cell').mouseenter()")
    refute_selector '.hover-tip', visible: :all
  end

  test 'm0b025', %w(
  | locking clears a tip that is already showing: if a predict/auto-revert
  | hover-tip is visible at the instant the poll locks, the lock removes it.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    # hover to show the tip and leave it showing (no mouseleave)
    execute_script("jQuery('#predict-checkbox-cell').mouseenter()")
    assert_selector '.hover-tip', visible: :all

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")
    assert_selector 'body.mobbing-stale', wait: 5

    refute_selector '.hover-tip', visible: :all
  end

  test 'm0b026', %w(
  | locking disables the download button: after the poll locks on another tab's
  | event, the download button is disabled so a stale tab cannot export a stale
  | session.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '.download[disabled]', visible: :all   # enabled on a fresh kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector '.download[disabled]', visible: :all
  end

  test 'm0b028', %w(
  | the lock overlay supersedes an open run-tests dialog: with a #run-tests-info
  | dialog already open (eg a "still preparing" message), when the poll locks on
  | another laptop's event it closes that dialog and shows the overlay instead of
  | colliding on showModal.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("document.getElementById('run-tests-info').showModal()")
    assert_selector '#run-tests-info[open]'

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector '#mobbing-overlay', wait: 5
    refute_selector '#run-tests-info[open]'
  end

  test 'm0b029', %w(
  | dismissing the lock overlay leaves the tab locked: clicking Dismiss removes the
  | overlay so the user can reach and copy their edits, but the page stays locked
  | (body.mobbing-stale, [test] disabled) and the app-bar reminder names another
  | laptop.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")
    assert_selector '#mobbing-overlay', wait: 5

    # Click via execute_script: headless Firefox cannot scroll the fixed-overlay
    # button into view to click it (other tests drive clicks the same way).
    execute_script("document.getElementById('mobbing-overlay-dismiss').click()")

    refute_selector '#mobbing-overlay'
    assert_selector 'body.mobbing-stale'
    assert_selector '#test-button[disabled]'
    assert_selector '#mobbing-app-bar-message', text: 'another laptop'
  end

  test 'm0b030', %w(
  | a foreign event with no laptop_id is stale and does not throw: an event above
  | knownHead lacking a laptop_id (a legacy or malformed writer) counts as not-mine
  | so it locks, and cd.isStale handles it without throwing.
  ) do
    open_a_kata_edit_page

    my_tab = 'b2' * 16
    known_head = 1
    stream = [
      { 'index' => 0 },                                                            # create
      { 'index' => 1, 'laptop_id' => stored_id('a1' * 16, my_tab), 'colour' => 'red' },
      { 'index' => 2, 'colour' => 'green' },   # no laptop_id (legacy / malformed writer)
    ]

    assert is_stale(stream, known_head, my_tab),
      'stale: a no-laptop_id event above knownHead is not mine'
  end

  test 'm0b033', %w(
  | a foreign event with no laptop_id locks with the generic message: when the poll
  | reads an event above knownHead that has no laptop_id (unclassifiable), it locks
  | the tab and shows the generic app-bar reminder, not the overlay.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    # Stub the read so the poll deterministically sees an event above knownHead
    # (seeded to 0 at load) that has no laptop_id - a legacy / malformed writer.
    execute_script(
      "cd.mobbingPoll.stop();" \
      "cd.lib.getEvents = (id, cb) => { cb([{index: 0}, {index: 1, colour: 'red'}]); return Promise.resolve(); };"
    )
    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector 'body.mobbing-stale', wait: 5
    assert_selector '#mobbing-app-bar-message', text: 'This kata changed. Refresh to continue.'
    refute_selector '#mobbing-overlay'
  end

  test 'm0b034', %w(
  | becoming visible evaluates immediately: a tab that went stale locks as soon as
  | it is brought to the foreground (visibilitychange), without waiting for the
  | next poll interval.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    # Huge interval so only the visibilitychange can trigger a check.
    execute_script("cd.mobbingPoll.stop(); cd.mobbingPoll.intervalMs = 999999; cd.mobbingPoll.enable()")

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    refute_selector 'body.mobbing-stale'   # huge interval: not locked yet
    execute_script("document.dispatchEvent(new Event('visibilitychange'))")

    assert_selector 'body.mobbing-stale', wait: 5
  end

  test 'm0b035', %w(
  | polling backs off while the tab is hidden: with document.hidden a check does not
  | lock even when the tab is stale; once visible again the same check locks.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("cd.mobbingPoll.stop(); cd.mobbingPoll.intervalMs = 999999; cd.mobbingPoll.enable()")

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    # Pretend the tab is hidden: a direct check must not lock.
    execute_script("Object.defineProperty(document, 'hidden', {configurable: true, get: () => true})")
    execute_script("cd.mobbingPoll.check()")
    sleep 0.5
    refute_selector 'body.mobbing-stale'

    # Foreground again: the same check now locks.
    execute_script("Object.defineProperty(document, 'hidden', {configurable: true, get: () => false})")
    execute_script("cd.mobbingPoll.check()")
    assert_selector 'body.mobbing-stale', wait: 5
  end

  test 'm0b036', %w(
  | the poll stops on page hide: dispatching pagehide clears the interval so no
  | stray poll runs as the page goes away (cd.mobbingPoll.polling becomes false).
  ) do
    open_a_kata_edit_page

    assert evaluate_script('cd.mobbingPoll.polling'), 'poll running after load'
    execute_script("window.dispatchEvent(new Event('pagehide'))")
    refute evaluate_script('cd.mobbingPoll.polling'), 'poll stopped after pagehide'
  end

  test 'm0b012', %w(
  | locking disables the review-page action buttons: after the poll locks,
  | cd.mobbingPoll.locked is set, the checkout, revert and fork buttons are
  | disabled, and cd.revertOrCheckout bails before its POST so a stale tab
  | commits nothing.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a tab_id this browser cannot have
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")
    assert_selector 'body.mobbing-stale', wait: 5

    assert evaluate_script('cd.mobbingPoll.locked'), 'mobbingPoll.locked set after lock'
    # The buttons live in the (hidden) review page, hence visible: :all.
    assert_selector '#checkout-button[disabled]', visible: :all
    assert_selector '#revert-button[disabled]', visible: :all
    assert_selector '#fork-button[disabled]', visible: :all

    # The guard makes revertOrCheckout return before its POST, so calling it on a
    # locked tab commits nothing.
    count = saver.kata_events(id).size
    execute_script('cd.revertOrCheckout()')
    sleep 0.5
    assert_equal count, saver.kata_events(id).size, 'checkout/revert commits nothing when locked'
  end

  test 'm0b013', %w(
  | locking on another laptop's event shows the full-page lock overlay: after the
  | poll locks, a dimmed overlay with a single Dismiss button covers the page.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    refute_selector '#mobbing-overlay'   # no overlay on a fresh, in-sync kata

    files = saver.kata_event(id, 0)['files']
    other = stored_id('a1' * 16, 'ff' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector '#mobbing-overlay', wait: 5
    assert_selector '#mobbing-overlay-dismiss', text: 'Dismiss'
    refute_selector '#mobbing-overlay-refresh'   # single Dismiss button now
  end

  test 'm0b014', %w(
  | a [test] write carries this tab's id: the committed event's laptop_id is the
  | laptop_id cookie's first 32 chars (the laptop half) concatenated with this
  | tab's tab_id, so the poll can recognise the tab's own writes.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    cookie_half = evaluate_script(
      "document.cookie.split('; ').find((c) => c.startsWith('laptop_id=')).split('=')[1].slice(0, 32)"
    )
    tab_id = evaluate_script('cd.mobbingPoll.tabId')

    # Drive the production run-tests path directly (the [test] button can't be
    # scrolled into view to click in headless Firefox; other browser tests do the
    # same via execute_script).
    execute_script('cd.kata.runTests(function(){})')

    event = wait_for_new_event(id, 1)   # the fresh kata starts with 1 event
    assert_equal cookie_half + tab_id, event['laptop_id'],
      'committed event laptop_id is laptopHalf + tabId'
  end

  test 'm0b015', %w(
  | a file-event write carries this tab's id: the committed file event's laptop_id
  | is the laptop half plus this tab's tab_id. All file create/rename/delete/edit
  | events go through one POST, so covering file_create covers them all.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    cookie_half = evaluate_script(
      "document.cookie.split('; ').find((c) => c.startsWith('laptop_id=')).split('=')[1].slice(0, 32)"
    )
    tab_id = evaluate_script('cd.mobbingPoll.tabId')

    execute_script('cd.fileCreateITE("scratch.txt", function(){})')

    event = wait_for_new_event(id, 1)
    assert_equal cookie_half + tab_id, event['laptop_id'],
      'committed file event laptop_id is laptopHalf + tabId'
  end

  test 'm0b016', %w(
  | edit.erb starts the poll on load: cd.mobbingPoll.polling is true after the
  | edit page loads, with no manual enable - so the stale-tab detection is live.
  ) do
    open_a_kata_edit_page

    assert evaluate_script('cd.mobbingPoll.polling'), 'poll is started on edit-page load'
  end

  test 'm0b017', %w(
  | the laptop-id meta tag: the page carries a <meta name="laptop-id"> holding the
  | 32-hex laptop half, so the poll can choose its message (another laptop vs tab).
  ) do
    open_a_kata_edit_page

    laptop_half = evaluate_script(
      "document.querySelector('meta[name=laptop-id]').getAttribute('content')"
    )
    assert_match(/\A[0-9a-f]{32}\z/, laptop_half, 'laptop-id meta holds 32 hex chars')
  end

  test 'm0b018', %w(
  | another-laptop presentation is the overlay: when the locking event's laptop
  | half differs from mine, the full-page overlay names another laptop and no
  | app-bar message is shown.
  ) do
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    other = stored_id('c3' * 16, 'd4' * 16)   # a different laptop half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector '#mobbing-overlay', text: 'another laptop', wait: 5
    refute_selector '#mobbing-app-bar-message'   # no app-bar reminder while the overlay is up
  end

  test 'm0b019', %w(
  | another-tab presentation is the app-bar message: when the locking event shares
  | my laptop half but has a different tab, an app-bar message names another tab
  | and no overlay is shown.
  ) do
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    my_laptop = evaluate_script(
      "document.querySelector('meta[name=laptop-id]').getAttribute('content')"
    )
    other = my_laptop + ('e5' * 16)   # my laptop half, a different tab half
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), other, next_tab_seq)

    execute_script("cd.mobbingPoll.intervalMs = 150; cd.mobbingPoll.enable()")

    assert_selector '#mobbing-app-bar-message', text: 'another tab', wait: 5
    refute_selector '#mobbing-overlay'
  end

  private

  # Poll saver until the committed event count exceeds prior_count; return the
  # last committed event.
  def wait_for_new_event(id, prior_count)
    30.times do
      events = saver.kata_events(id)
      return events.last if events.size > prior_count
      sleep 0.3
    end
    flunk "no new event committed beyond #{prior_count}"
  end

  # Load a kata edit page so app.js defines cd.isStale in the browser.
  def open_a_kata_edit_page
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
  end

  # Evaluate the production predicate cd.isStale in the browser.
  def is_stale(events, known_head, my_tab_id)
    evaluate_script("cd.isStale(#{events.to_json}, #{known_head}, #{my_tab_id.to_json})")
  end

  # True when every CodeMirror editor on the page is read-only.
  def all_editors_read_only?
    evaluate_script(
      "Array.from(document.querySelectorAll('.CodeMirror'))" \
      ".every((div) => div.CodeMirror.getOption('readOnly'))"
    )
  end

  # The value stored in a committed event's laptop_id field: the browser's laptop
  # id half and its per-tab id half concatenated into one string (saver stores the
  # single string; web splits it back into the two halves).
  def stored_id(laptop, tab)
    laptop + tab
  end

end
