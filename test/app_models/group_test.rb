require_relative 'app_models_test_base'

class GroupTest < AppModelsTestBase

  def self.hex_prefix
    '1414D2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A9',
  'a group with an arbitrary id does not exist' do
    refute groups['123AbZ'].exists?
  end

  test '6A0', %w(
  groups[''] is false to simplify ported implementation
  ) do
    refute groups[''].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A2',
  'a group cannot be created from a manifest missing any required property' do
    manifest = starter_manifest
    manifest.delete('image_name')
    error = assert_raises(ServiceError) { groups.new_group(manifest) }
    info = JSON.parse(error.message)
    assert_equal 'SaverService', info['class']
    assert_equal 'malformed:manifest:missing key[image_name]', info['message']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A1', %w(
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

  test '6A3', %w(
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

  test '6A4', %w(
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

=begin
  test '6A5', %w(
  the age (seconds) of a group is zero until one member becomes active
  and then it is age of the most recent event
  ) do
    group = create_group([2018,30,11, 9,34,56])
    assert_equal 0, group.age
    kata = group.join
    assert_equal 0, group.age
    kata.ran_tests(1, kata.files, [2018,30,11, 9,35,8], '', '', 0, 'green')
    assert_equal 14, group.age
  end
=end

  private

  def create_group(t = time_now)
    groups.new_group(starter_manifest(t))
  end

  def starter_manifest(t = time_now)
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = t
    manifest
  end

end
