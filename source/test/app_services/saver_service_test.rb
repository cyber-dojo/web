require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

class SaverServiceTest < AppServicesTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJX',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    _stdout, _stderr = capture_stdout_stderr do
      error = assert_raises(SaverService::Error) { saver.ready? }
      assert_equal 'body is not JSON', error.message, :error_message
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJY',
  'response.body failure on a post call is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    _stdout, _stderr = capture_stdout_stderr do
      error = assert_raises(SaverService::Error) { saver.group_join('some_id') }
      assert_equal 'body is not JSON', error.message, :error_message
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ0',
  'ready?() smoke test' do
    assert saver.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ1',
  'group_create() smoke test' do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    assert saver.group_exists?(gid), "saver.group_exists?(#{gid})"
    actual = saver.group_manifest(gid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ2',
  'kata_create() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    assert saver.kata_exists?(kid), "saver.kata_exists?(#{kid})"
    actual = saver.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ3',
  'group_join() - group_joined() smoke test' do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    kid = saver.group_join(gid)
    assert saver.kata_exists?(kid), "saver.kata_exists?(#{kid})"
    actual = saver.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
    joined = saver.group_joined(gid)
    assert_equal 1, joined.size
    avatar_index = joined.keys[0]
    assert_equal kid, joined[avatar_index]["id"]
    assert_equal 1, joined[avatar_index]["events"].size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ2',
  'kata_ran_tests() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_ran_tests(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, ran_summary('amber'), laptop_id, next_tab_seq)
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ3',
  'kata_predicted_right() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_predicted_right(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'red',
      predicted: 'red'
    }, laptop_id, next_tab_seq)
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'D1EQJ4',
  'kata_predicted_wrong() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_predicted_wrong(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'red',
      predicted: 'green'
    }, laptop_id, next_tab_seq)
    assert_equal 2, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ5',
  'kata_reverted() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_ran_tests(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, ran_summary('green'), laptop_id, next_tab_seq)
    saver.kata_ran_tests(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      duration: duration,
      colour: 'amber',
      predicted: 'red'
    }, laptop_id, next_tab_seq)
    saver.kata_reverted(kid, manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      colour: 'green',
      revert: [kid, 1]
    }, laptop_id, next_tab_seq)
    assert_equal 4, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJ6',
  'kata_checked_out() smoke test' do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    kid1 = saver.group_join(gid)
    saver.kata_ran_tests(kid1, manifest['visible_files'], content('stdout'), content('stderr'), 0, ran_summary('red'), laptop_id, next_tab_seq)
    saver.kata_ran_tests(kid1, manifest['visible_files'], content('stdout'), content('stderr'), 0, ran_summary('amber'), laptop_id, next_tab_seq)
    kid2 = saver.group_join(gid)
    saver.kata_checked_out(kid2, manifest['visible_files'], content('stdout'), content('stderr'), 0, {
      colour: 'red',
      checkout: {
        id: kid1,
        index: 2,
        avatarIndex: 46
      }
    }, laptop_id, next_tab_seq)
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
    next_index = saver.kata_file_edit(kid, files, laptop_id, next_tab_seq)
    assert_equal 2, next_index
  end

  test 'D1EQJ8',
  'kata_file_create() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    next_index = saver.kata_file_create(kid, manifest['visible_files'], 'new_file.txt', laptop_id, next_tab_seq)
    assert_equal 2, next_index
  end

  test 'D1EQJ9',
  'kata_file_delete() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    existing_filename = manifest['visible_files'].keys.first
    next_index = saver.kata_file_delete(kid, manifest['visible_files'], existing_filename, laptop_id, next_tab_seq)
    assert_equal 2, next_index
  end

  test 'D1EQJA',
  'kata_file_rename() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    old_name = manifest['visible_files'].keys.first
    next_index = saver.kata_file_rename(kid, manifest['visible_files'], old_name, 'renamed_file.txt', laptop_id, next_tab_seq)
    assert_equal 2, next_index
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ5',
  'kata_event() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    actual = saver.kata_event(kid, -1)
    assert_equal manifest['visible_files'], actual['files']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EeJ6',
  'kata_events() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    actual = saver.kata_events(kid)
    assert_equal 1, actual.size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJB',
  'kata_option_set() and kata_option_get() smoke test' do
    kid = saver.kata_create(starter_manifest)
    saver.kata_option_set(kid, 'colour', 'off')
    assert_equal 'off', saver.kata_option_get(kid, 'colour')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJC',
  'kata_download() smoke test' do
    manifest = starter_manifest
    manifest['version'] = 2
    kid = saver.kata_create(manifest)
    result = saver.kata_download(kid)
    assert_equal 2, result.size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJD',
  'kata_fork() smoke test' do
    kid = saver.kata_create(starter_manifest)
    forked_id = saver.kata_fork(kid, 0)
    assert saver.kata_exists?(forked_id)
  end

  test 'D1EQJE',
  'group_fork() smoke test' do
    kid = saver.kata_create(starter_manifest)
    forked_id = saver.group_fork(kid, 0)
    assert saver.group_exists?(forked_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJF',
  'diff_lines() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    files = manifest['visible_files']
    result = saver.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, ran_summary('red'), laptop_id, next_tab_seq)

    files['hiker.sh']['content'] = files['hiker.sh']['content'].sub('6 * 9', '6 * 7')
    result = saver.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, ran_summary('green'), laptop_id, next_tab_seq)

    diffs = saver.diff_lines(kid, 1, result['next_index'] - 1)

    changed = diffs.select { |d| d['type'] == 'changed' }
    assert_equal 1, changed.size
    assert_equal 'hiker.sh', changed[0]['new_filename']
    assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 5 }, changed[0]['line_counts'])

    unchanged = diffs.select { |d| d['type'] == 'unchanged' }
    assert_equal 4, unchanged.size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D1EQJG',
  'diff_summary() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    files = manifest['visible_files']
    result = saver.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, ran_summary('red'), laptop_id, next_tab_seq)

    files['hiker.sh']['content'] = files['hiker.sh']['content'].sub('6 * 9', '6 * 7')
    result = saver.kata_ran_tests(kid, files, content('stdout'), content('stderr'), 0, ran_summary('green'), laptop_id, next_tab_seq)

    diffs = saver.diff_summary(kid, 1, result['next_index'] - 1)

    changed = diffs.select { |d| d['type'] == 'changed' }
    assert_equal 1, changed.size
    assert_equal 'hiker.sh', changed[0]['new_filename']
    assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 5 }, changed[0]['line_counts'])
    assert_nil changed[0]['lines']

    unchanged = diffs.select { |d| d['type'] == 'unchanged' }
    assert_equal 4, unchanged.size
  end

end
