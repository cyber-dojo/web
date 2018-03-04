require_relative 'app_services_test_base'

class StorerServiceTest < AppServicesTestBase

  def self.hex_prefix
    'C0946E'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerService')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '51A',
  'non-existant kata-id raises exception' do
    error = assert_raises (StandardError) {
      storer.kata_manifest(kata_id)
    }
    assert error.message.end_with?('invalid kata_id')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '301',
  'smoke test storer-service scenario' do

    refute all_katas_ids.include? kata_id
    refute storer.kata_exists?(kata_id)

    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = creation_time
    storer.create_kata(manifest)

    assert storer.kata_exists?(kata_id)
    assert all_katas_ids.include? kata_id

    assert_equal({}, storer.kata_increments(kata_id))
    assert_equal kata_id, storer.completed(kata_id[0..5])
    assert_equal [], storer.started_avatars(kata_id)

    refute storer.avatar_exists?(kata_id, 'lion')
    assert_equal 'lion', storer.start_avatar(kata_id, ['lion'])
    assert storer.avatar_exists?(kata_id, 'lion')

    assert_equal({ 'lion' => [tag0] }, storer.kata_increments(kata_id))
    assert_equal ['lion'], storer.started_avatars(kata_id)
    files0 = storer.kata_manifest(kata_id)['visible_files']
    assert_equal files0, storer.tag_visible_files(kata_id, 'lion', tag=0)
    assert_equal [tag0], storer.avatar_increments(kata_id, 'lion')

    files1 = kata.visible_files
    files1['readme.txt'] = 'more info'
    args = []
    args << kata_id
    args << 'lion'
    args << files1
    args << (now = [2016,12,8, 8,3,23])
    args << (output = "Expected: 42\nActual: 54")
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)

    tag1 = { 'colour' => colour, 'time' => now, 'number' => 1 }
    assert_equal({ 'lion' => [tag0,tag1] }, storer.kata_increments(kata_id))
    assert_equal [tag0,tag1], storer.avatar_increments(kata_id, 'lion')

    files1['output'] = output
    assert_equal files1, storer.avatar_visible_files(kata_id, 'lion')

    json = storer.tags_visible_files(kata_id, 'lion', was_tag=0, now_tag=1)
    assert_equal files0, json['was_tag']
    assert_equal files1, json['now_tag']
  end

end
