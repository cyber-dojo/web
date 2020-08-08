require_relative 'app_models_test_base'
require_relative '../../app/services/saver_service'

class GroupTest < AppModelsTestBase

  def self.hex_prefix
    '1P4'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B7F', %w(
  using existing group.methods (except for exists?)
  when params does not specify a version number
  forces schema.version determination via the manifest
  ) do
    set_saver_class('SaverService')
    groups = Groups.new(self, {})
    group = groups['chy6BJ']
    assert_equal 'Ruby, MiniTest', group.manifest.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?

  v_tests [0,1], '5A5', %w(
  exists? is true,
  for a well-formed group-id that exists,
  when saver is online
  ) do
    in_new_group do |group|
      assert group.exists?
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '5A6', %w(
  exists? is false,
  for a well-formed group-id that does not exist,
  when saver is online
  ) do
    refute groups['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '5A7', %w(
  exists? is false,
  for a malformed group-id,
  when saver is online
  ) do
    refute groups[42].exists?, 'Integer'
    refute groups[nil].exists?, 'nil'
    refute groups[[]].exists?, '[]'
    refute groups[{}].exists?, '{}'
    refute groups[true].exists?, 'true'
    refute groups[''].exists?, 'length == 0'
    refute groups['12345'].exists?, 'length == 5'
    refute groups['12345i'].exists?, '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '5A8', %w(
  exists? raises,
  when saver is offline
  ) do
    set_saver_class('SaverExceptionRaiser')
    assert_raises(SaverService::Error) {
      groups['123AbZ'].exists?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # ...

  v_tests [0,1], '6A3', %w(
  a group can be created from a well-formed manifest,
  and is initially empty
  ) do
    in_new_group do |group|
      assert_schema_version(group)
      assert_equal group.id, groups[group.id].id
      assert group.exists?
      assert group.empty?
      assert_equal 0, group.size
      assert_equal [], group.katas
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A4', %w(
  a group's creation time is set in the manifest used to create it
  ) do
    now = [2018,11,30, 9,34,56,6453]
    @time = TimeStub.new(now)
    in_new_group do |group|
      assert_equal Time.mktime(*now), group.created
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A5', %w(
  when you join a group you increase its size by one,
  and are a member of the group
  ) do
    in_new_group do |group|
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
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A6', %w(
  you can join 64 times and then the group is full
  ) do
    in_new_group do |group|
      64.times do |size|
        kata = group.join
        refute_nil kata
        assert_equal size+1, group.size
      end
      kata = group.join
      assert_nil kata
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A7', %w(
  the age (seconds) of a group is zero until one member becomes active
  and then it is age of the most recent event
  ) do
    @time = TimeStub.new([2018,11,30, 9,34,56,6543])
    in_new_group do |group|
      assert_equal 0, group.age
      kata = group.join
      assert_equal 0, group.age
      stdout = content('')
      stderr = content('')
      status = 0
      kata.ran_tests(kata.id, 1, kata.files, stdout, stderr, status, {
        'time' => [2018,11,30, 9,35,8,7564],
        'duration' => duration,
        'colour' => 'green',
        'predicted' => 'none'
      })
      assert_equal 12, group.age
    end
  end

#- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '6A8', %w(
  a group's manifest is identical to the starter-manifest it was created with
  and does not have group_id nor group_index properties
  ) do
    @time = TimeStub.new([2019,9,24, 12,35,46,214204])
    m = starter_manifest
    in_new_group do |group|
      am = group.manifest
      assert_nil am.group_id
      assert_nil am.group_index

      assert_equal group.id, am.id
      assert_equal m['display_name'], am.display_name
      assert_equal m['image_name'], am.image_name
      assert_equal m['exercise'], am.exercise
      assert_equal m['tab_size'], am.tab_size
      assert_equal m['created'], am.created

      fe = ['.rb']
      assert_equal fe, m['filename_extension']
      assert_equal fe, am.filename_extension

      refute m.has_key?('highlight_filenames')
      assert_equal [], am.highlight_filenames, 'default highlight_filenames'

      refute m.has_key?('progress_regexs')
      assert_equal [], am.progress_regexs, 'default progress_regexs'
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '45C', %w(
  In Version-0 events does not raise when id does not exist
  In Version-1 events raises when id does not exist
  ) do
    groups = Groups.new(self, {version:0})
    group = groups['123456']
    group.events
    groups = Groups.new(self, {version:1})
    group = groups['123456']
    assert_raises { group.events }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '45E', %w(
  In Version-0 events is hash of each avatars events when id does exist
  ) do
    manifest = starter_manifest
    manifest['version'] = schema_version
    group = groups.new_group(manifest)
    assert_equal({}, group.events)
    k1 = group.join
    k1_events = {
      'index' => k1.avatar_index,
      'events' => [
        { 'event' => 'created',
          'time' => k1.manifest.created
        }
      ]
    }
    if v_test?(1)
      k1_events['events'][0]['index'] = 0
    end
    assert_equal({k1.id=>k1_events}, group.events)
    k2 = group.join
    k2_events = {
      'index' => k2.avatar_index,
      'events' => [
        { 'event' => 'created',
          'time' => k2.manifest.created
        }
      ]
    }
    if v_test?(1)
      k2_events['events'][0]['index'] = 0
    end
    assert_equal({
      k1.id => k1_events,
      k2.id => k2_events
    }, group.events)
  end

end
