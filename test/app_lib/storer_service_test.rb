require_relative './app_lib_test_base'

class StorerServiceTest < AppLibTestBase

  #------------------------------------------------------------------
  # In docker-compose.yml the storer service is setup with
  #     environment: [ CYBER_DOJO_KATAS_ROOT=/tmp/cyber-dojo/katas ]
  # It does *not* volume-mount the katas data-container.

  test 'C6DCD7451A',
  'non-existant kata-id raises exception' do
    kata_id = 'C6DCD7451A'
    error = assert_raises (StandardError) { storer.kata_manifest(kata_id) }
    assert error.message.start_with?('StorerService:kata_manifest')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C6DE6CD301',
  'smoke test storer-service' do
    kata_id = 'C6DE6CD301'
    assert_equal 'StorerService', storer.class.name

    assert_equal '/tmp/cyber-dojo/katas', storer.path

    refute all_ids.include? kata_id

    manifest = make_manifest(kata_id)
    storer.create_kata(manifest)

    assert all_ids.include? kata_id

    expected = manifest
    actual = storer.kata_manifest(kata_id)
    assert_equal expected.keys.size, actual.keys.size
    expected.each do |key, value|
      assert_equal value, actual[key.to_s]
    end
    assert_equal kata_id, storer.completed(kata_id[0..5])
    assert_equal [], storer.started_avatars(kata_id)
    assert_equal lion, storer.start_avatar(kata_id, [lion])
    assert_equal [lion], storer.started_avatars(kata_id)
    files0 = storer.kata_manifest(kata_id)['visible_files']
    assert_equal files0, storer.tag_visible_files(kata_id, lion, tag=0)
    assert_equal [tag0], storer.avatar_increments(kata_id, lion)

    args = []
    args << kata_id
    args << lion
    args << (files1 = edited_files)
    args << (now = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)

    assert_equal [
      tag0,
      { 'colour' => colour, 'time' => now, 'number' => 1 }
    ], storer.avatar_increments(kata_id, lion)

    files1['output'] = output
    assert_equal files1, storer.avatar_visible_files(kata_id, lion)

    hash = storer.tags_visible_files(kata_id, lion, was_tag=0, now_tag=1)
    assert_equal files0, hash['was_tag']
    assert_equal files1, hash['now_tag']
  end

end
