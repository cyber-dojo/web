require_relative 'app_models_test_base'
require_relative '../../app/services/saver_exception'

class GroupTest < AppModelsTestBase

  def self.hex_prefix
    '1P4'
  end

  def hex_setup
    set_saver_class('SaverFake')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '5A6', %w(
  a group with an invalid returns false for exist?
  viz it does not raise
  ) do
    refute groups[42].exists?, 'Integer'
    refute groups[nil].exists?, 'nil'
    refute groups[[]].exists?, '[]'
    refute groups[{}].exists?, '{}'
    refute groups[true].exists?, 'true'
    refute groups[''].exists?, 'length == 0'
    refute groups['12345'].exists?, 'length == 5'
    refute groups['12345i'].exists?, '!Base58'
    refute groups['123AbZ'].exists?, 'no group with that id'
  end

  test '5A8',
  'when saver is offline, group.exists? raises' do
    set_saver_class('SaverExceptionRaiser')
    assert_raises(SaverException) {
      groups['123AbZ'].exists?
    }
  end

  test '5A7',
  'a group with a valid id exists' do
    group = create_group
    assert groups[group.id].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '6A2',
  'a group cannot be created from a manifest missing any required property' do
    manifest = starter_manifest
    manifest.delete('image_name')
    error = assert_raises(SaverException) { groups.new_group(manifest) }
    info = JSON.parse(error.message)
    assert_equal 'SaverService', info['class']
    assert_equal 'malformed:manifest["image_name"]:missing:', info['message']
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A3', %w(
  a group can be created from a well-formed manifest,
  and is initially empty
  ) do
    group = create_group
    assert_equal group.id, groups[group.id].id
    assert group.exists?
    assert group.empty?
    assert_equal 0, group.size
    assert_equal [], group.katas
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A4', %w(
  a group's creation time is set in the manifest used to create it
  ) do
    t = [2018,11,30, 9,34,56,6453]
    group = create_group(t)
    assert_equal Time.mktime(*t), group.created
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A5', %w(
  when you join a group you increase its size by one,
  and are a member of the group
  ) do
    group = create_group
    expected_ids = []
    actual_ids = lambda { group.katas.map{ |kata| kata.id } }

    kata1 = group.join
    expected_ids << kata1.id
    assert_equal 1, group.size
    assert_equal expected_ids.sort, actual_ids.call.sort

    kata2 = group.join
    expected_ids << kata2.id
    assert_equal 2, group.size
    assert_equal expected_ids.sort, actual_ids.call.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A6', %w(
  you can join 64 times and then the group is full
  ) do
    group = create_group
    indexes = (0..63).to_a.shuffle
    64.times do
      kata = group.join(indexes)
      refute_nil kata
      indexes.rotate!
    end
    kata = group.join(indexes)
    assert_nil kata
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A7', %w(
  the age (seconds) of a group is zero until one member becomes active
  and then it is age of the most recent event
  ) do
    group = create_group([2018,11,30, 9,34,56,6543])
    assert_equal 0, group.age
    kata = group.join
    assert_equal 0, group.age
    stdout = file('')
    stderr = file('')
    status = 0
    kata.ran_tests(1, kata.files, [2018,11,30, 9,35,8,7564], duration, stdout, stderr, status, 'green')
    assert_equal 12, group.age
  end

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

#- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A8', %w(
  a group's manifest is identical to the manifest it was created with
  and does not have group_id nor group_index properties
  ) do
    m = starter_manifest
    group = groups.new_group(m)
    am = group.manifest
    assert_nil am.group_id
    assert_nil am.group_index

    assert_equal group.id, am.id
    assert_equal m['display_name'], am.display_name
    assert_equal m['image_name'], am.image_name
    assert_equal m['exercise'], am.exercise
    assert_equal m['tab_size'], am.tab_size
    assert_equal m['created'], am.created

    hf = %w( coverage/\\.last_run\\.json coverage/\\.resultset\\.json ) # regex
    assert_equal hf, m['hidden_filenames']
    assert_equal hf, am.hidden_filenames

    fe = ['.rb']
    assert_equal fe, m['filename_extension']
    assert_equal fe, am.filename_extension

    refute m.has_key?('highlight_filenames')
    assert_equal [], am.highlight_filenames, 'default highlight_filenames'

    refute m.has_key?('max_seconds')
    assert_equal 10, am.max_seconds, 'default max_seconds'

    refute m.has_key?('progress_regexs')
    assert_equal [], am.progress_regexs, 'default progress_regexs'
  end

end
