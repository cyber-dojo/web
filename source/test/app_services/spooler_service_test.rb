require_relative 'app_services_test_base'
require 'json'

# web POSTs the nine event-writes to the spooler, which durably buffers them and
# whose drainer forwards them to saver asynchronously. Each smoke test seeds one
# write via the spooler, waits for it to drain (poll saver until the write's
# light appears, matched by its tab_seq + colour), then reads the committed
# events back from saver.
class SpoolerServiceTest < AppServicesTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ2',
  'kata_ran_tests() smoke test' do
    kid = saver.kata_create(starter_manifest)
    tab_seq = next_tab_seq
    spooler.kata_ran_tests(kid, starter_manifest['visible_files'], content('stdout'), content('stderr'), 0, ran_summary('amber'), laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'amber')
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ3',
  'kata_predicted_right() smoke test' do
    kid = saver.kata_create(starter_manifest)
    tab_seq = next_tab_seq
    spooler.kata_predicted_right(kid, starter_manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'red',
      predicted: 'red'
    }, laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'red')
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ4',
  'kata_predicted_wrong() smoke test' do
    kid = saver.kata_create(starter_manifest)
    tab_seq = next_tab_seq
    spooler.kata_predicted_wrong(kid, starter_manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'red',
      predicted: 'green'
    }, laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'red')
    assert_equal 2, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ5',
  'kata_reverted() smoke test' do
    kid = saver.kata_create(starter_manifest)
    files = starter_manifest['visible_files']
    spooler.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, ran_summary('green'), laptop_id, next_tab_seq)
    spooler.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'amber',
      predicted: 'red'
    }, laptop_id, next_tab_seq)
    reverted_seq = next_tab_seq
    spooler.kata_reverted(kid, files, content('stdout'), content('stderr'), 0, {
      colour: 'green',
      revert: [kid, 1]
    }, laptop_id, reverted_seq)
    # The drainer forwards per writer in tab_seq order, so once the reverted
    # write (the last tab_seq) has drained the two earlier writes have too.
    wait_until_drained(kid, reverted_seq, 'green')
    assert_equal 4, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ6',
  'kata_checked_out() smoke test' do
    gid = saver.group_create(starter_manifest)
    kid1 = saver.group_join(gid)
    files = starter_manifest['visible_files']
    spooler.kata_ran_tests(kid1, files, content('stdout'), content('stderr'), 0, ran_summary('red'), laptop_id, next_tab_seq)
    spooler.kata_ran_tests(kid1, files, content('stdout'), content('stderr'), 0, ran_summary('amber'), laptop_id, next_tab_seq)
    kid2 = saver.group_join(gid)
    checkout_seq = next_tab_seq
    spooler.kata_checked_out(kid2, files, content('stdout'), content('stderr'), 0, {
      colour: 'red',
      checkout: {
        id: kid1,
        index: 2,
        avatarIndex: 46
      }
    }, laptop_id, checkout_seq)
    wait_until_drained(kid2, checkout_seq, 'red')
    assert_equal 2, saver.kata_events(kid2).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ7',
  'kata_file_edit() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    files = manifest['visible_files']
    files[files.keys.first]['content'] += "\n# comment"
    tab_seq = next_tab_seq
    spooler.kata_file_edit(kid, files, laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'file_edit')
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ8',
  'kata_file_create() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    tab_seq = next_tab_seq
    spooler.kata_file_create(kid, manifest['visible_files'], 'new_file.txt', laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'file_create')
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ9',
  'kata_file_delete() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    existing_filename = manifest['visible_files'].keys.first
    tab_seq = next_tab_seq
    spooler.kata_file_delete(kid, manifest['visible_files'], existing_filename, laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'file_delete')
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJA',
  'kata_file_rename() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    old_name = manifest['visible_files'].keys.first
    tab_seq = next_tab_seq
    spooler.kata_file_rename(kid, manifest['visible_files'], old_name, 'renamed_file.txt', laptop_id, tab_seq)
    wait_until_drained(kid, tab_seq, 'file_rename')
    assert_equal 2, saver.kata_events(kid).size
  end

end
