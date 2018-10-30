require_relative 'app_models_test_base'

class GroupTest < AppModelsTestBase

  def self.hex_prefix
    '1414D2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A0',
  'a group with an aribtrary id does not exist' do
    refute groups['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A1',
  'a new group can be created from a well-formed manifest and is initially empty' do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = time_now
    group = groups.new_group(manifest)
    assert_equal group.id, groups[group.id].id
    assert group.exists?
    assert group.empty?
    assert_equal 0, group.size
    assert_equal [], group.katas
    assert_equal 0, group.age
    assert_equal 'Ruby, MiniTest', group.manifest.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A2',
  'a new group cannot be created from a manifest missing any required property' do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest.delete('image_name')
    error = assert_raises(ServiceError) { groups.new_group(manifest) }
    info = JSON.parse(error.message)
    assert_equal 'SaverService', info['class']
    assert_equal 'malformed:manifest:missing key[image_name]', info['message']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '6A3', %w(
  joining a group results in a kata with an avatar's name
  which is member of the group
  ) do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = time_now
    group = groups.new_group(manifest)
    indexes = (0..63).to_a.shuffle
    kata = group.join(indexes)
    index = indexes[0]
    assert_equal group.id, kata.group.id
    assert_equal Avatars.names[index], kata.avatar_name

    refute group.empty?
    assert_equal 1, group.size
    assert_equal kata.id, group.katas[0].id
    assert_equal 0, group.age
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -


end
