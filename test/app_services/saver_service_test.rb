# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

class SaverServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D1E'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJX',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(SaverService::Error) { saver.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body is not JSON', json['message'], error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ0',
  'ready?() smoke test' do
    assert saver.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ1',
  'group_create() smoke test' do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    assert saver.group_exists?(gid), "saver.group_exists?(#{gid})"
    actual = saver.group_manifest(gid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ2',
  'kata_create() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    assert saver.kata_exists?(kid), "saver.kata_exists?(#{kid})"
    actual = saver.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ3',
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

  test 'QJ2',
  'kata_ran_tests() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_ran_tests(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('amber'))
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'QJ3',
  'kata_predicted_right() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_predicted_right(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, {
      duration: duration,
      colour: 'red',
      predicted: 'red'
    })
    assert_equal 2, saver.kata_events(kid).size
  end

  test 'QJ4',
  'kata_predicted_wrong() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_predicted_wrong(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, {
      duration: duration,
      colour: 'red',
      predicted: 'green'
    })
    assert_equal 2, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'QJ5',
  'kata_reverted() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    saver.kata_ran_tests(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('green'))
    saver.kata_ran_tests(kid, 2, manifest['visible_files'], 'stdout', 'stderr', 0, {
      duration: duration,
      colour: 'amber',
      predicted: 'red'
    })
    saver.kata_reverted(kid, 3, manifest['visible_files'], 'stdout', 'stderr', 0, {
      colour: 'green',
      revert: [kid, 1]
    })
    assert_equal 4, saver.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'QJ6',
  'kata_checked_out() smoke test' do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    kid1 = saver.group_join(gid)
    saver.kata_ran_tests(kid1, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('red'))
    saver.kata_ran_tests(kid1, 2, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('amber'))
    kid2 = saver.group_join(gid)
    saver.kata_checked_out(kid2, 1, manifest['visible_files'], 'stdout', 'stderr', 0, {
      colour: 'red',
      checkout: {
        id: kid1,
        index: 2,
        avatarIndex: 46
      }
    })
    assert_equal 2, saver.kata_events(kid2).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ5',
  'kata_event() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    actual = saver.kata_event(kid, -1)
    assert_equal manifest['visible_files'], actual['files']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ6',
  'kata_events() smoke test' do
    manifest = starter_manifest
    kid = saver.kata_create(manifest)
    actual = saver.kata_events(kid)
    assert_equal 1, actual.size
  end

end
