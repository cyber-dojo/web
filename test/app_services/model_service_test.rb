# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

class ModelServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D1E'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJX',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(ModelService::Error) { model.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body is not JSON', json['message'], error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ0',
  'ready?() smoke test' do
    assert model.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ1',
  'group_create() smoke test' do
    manifest = starter_manifest
    gid = model.group_create(manifest)
    assert model.group_exists?(gid), "model.group_exists?(#{gid})"
    actual = model.group_manifest(gid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ2',
  'kata_create() smoke test' do
    manifest = starter_manifest
    kid = model.kata_create(manifest)
    assert model.kata_exists?(kid), "model.kata_exists?(#{kid})"
    actual = model.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ3',
  'group_join() - group_joined() smoke test' do
    manifest = starter_manifest
    gid = model.group_create(manifest)
    kid = model.group_join(gid)
    assert model.kata_exists?(kid), "model.kata_exists?(#{kid})"
    actual = model.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
    joined = model.group_joined(gid)
    assert_equal 1, joined.size
    avatar_index = joined.keys[0]
    assert_equal kid, joined[avatar_index]["id"]
    assert_equal 1, joined[avatar_index]["events"].size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'QJ4',
  'kata_ran_tests() smoke test' do
    manifest = starter_manifest
    kid = model.kata_create(manifest)
    model.kata_ran_tests(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('amber'))
    assert_equal 2, model.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'QJ5',
  'kata_reverted() smoke test' do
    manifest = starter_manifest
    kid = model.kata_create(manifest)
    model.kata_ran_tests(kid, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('green'))
    model.kata_ran_tests(kid, 2, manifest['visible_files'], 'stdout', 'stderr', 0, {
      duration: duration,
      colour: 'amber',
      predicted: 'red'
    })
    model.kata_reverted(kid, 3, manifest['visible_files'], 'stdout', 'stderr', 0, {
      colour: 'green',
      revert: [kid, 1]
    })
    assert_equal 4, model.kata_events(kid).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'QJ6',
  'kata_checked_out() smoke test' do
    manifest = starter_manifest
    gid = model.group_create(manifest)
    kid1 = model.group_join(gid)
    model.kata_ran_tests(kid1, 1, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('red'))
    model.kata_ran_tests(kid1, 2, manifest['visible_files'], 'stdout', 'stderr', 0, ran_summary('amber'))
    kid2 = model.group_join(gid)
    model.kata_checked_out(kid2, 1, manifest['visible_files'], 'stdout', 'stderr', 0, {
      colour: 'red',
      checkout: {
        id: kid1,
        index: 2,
        avatarIndex: 46
      }
    })
    assert_equal 2, model.kata_events(kid2).size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ5',
  'kata_event() smoke test' do
    manifest = starter_manifest
    kid = model.kata_create(manifest)
    actual = model.kata_event(kid, -1)
    assert_equal manifest['visible_files'], actual['files']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ6',
  'kata_events() smoke test' do
    manifest = starter_manifest
    kid = model.kata_create(manifest)
    actual = model.kata_events(kid)
    assert_equal 1, actual.size
  end

end
