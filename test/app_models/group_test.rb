require_relative 'app_models_test_base'

class GroupTest < AppModelsTestBase

  def self.hex_prefix
    '1414D2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A0',
  'a group with an arbitrary id does not exist' do
    refute groups['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A2',
  'a group cannot be created from a manifest missing any required property' do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
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
    assert_equal 0, group.age
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A3', %w(
  when you join a group you increase its size by one,
  and are a member of the group
  ) do
    group = create_group
    kata1 = group.join
    assert_equal 1, group.size
    assert_equal [kata1.id], group.katas.map{ |kata| kata.id }
    kata2 = group.join
    assert_equal 2, group.size
    assert_equal [kata1.id, kata2.id].sort, group.katas.map{ |kata| kata.id }.sort
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
      index = indexes.shift
      indexes << index
    end
    kata = group.join(indexes)
    assert_nil kata
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def create_group
    groups.new_group(starter_manifest)
  end

  def starter_manifest
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = time_now
    manifest
  end

end
