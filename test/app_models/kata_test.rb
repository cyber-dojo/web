require_relative 'app_models_test_base'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'F3B488'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '860',
  'a kata with an arbitrary id does not exist' do
    refute katas['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '861',
  'a kata cannot be created from a manifest missing any required property' do
    manifest = starter_manifest
    manifest.delete('image_name')
    error = assert_raises(ServiceError) { katas.new_kata(manifest) }
    info = JSON.parse(error.message)
    assert_equal 'SaverService', info['class']
    assert_equal 'malformed:manifest["image_name"]:missing:', info['message']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '862', %w(
  an individual kata is created from a well-formed manifest,
  is empty,
  and is not a member of a group,
  ) do
    kata = create_kata
    assert kata.exists?

    assert_equal 0, kata.age

    assert_equal '', kata.stdout
    assert_equal '', kata.stderr
    assert_equal '', kata.status

    refute kata.active?
    assert_equal [], kata.lights

    assert_nil kata.group
    assert_equal '', kata.avatar_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '863', %w(
  a new group-kata can be created by joining a group,
  is empty,
  and is a member of the group
  ) do
    manifest = starter_manifest
    group = groups.new_group(manifest)
    indexes = (0..63).to_a.shuffle

    kata = group.join(indexes)

    assert_equal 0, kata.age

    assert_equal '', kata.stdout
    assert_equal '', kata.stderr
    assert_equal '', kata.status

    refute kata.active?
    assert_equal [], kata.lights

    refute_nil kata.group
    assert_equal group.id, kata.group.id
    assert_equal Avatars.names[indexes[0]], kata.avatar_name

    assert_equal 'Ruby, MiniTest', kata.manifest.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '864', %w(
  after run_tests()/ran_tests(),
  the kata is active,
  the kata is a bit older,
  there is a new traffic-light event,
  which is now the most recent event
  ) do
    kata = create_kata([2018,11,1, 9,13,56])
    manifest = kata.manifest
    params = {
      image_name:manifest.image_name,
      max_seconds:manifest.max_seconds,
      file_content:kata.files,
      file_hashes_incoming:kata.files,
      file_hashes_outgoing:kata.files,
      hidden_filenames:'[]'
    }
    kata.run_tests(params)
    kata.ran_tests(1, kata.files, [2018,11,1, 9,14,9], 'so', 'se', 39, 'red')
    assert_equal 13, kata.age
    assert kata.active?
    assert_equal 2, kata.events.size
    assert_equal 1, kata.lights.size
    light = kata.lights[0]
    assert_equal 'so', light.stdout
    assert_equal 'so', kata.stdout
    assert_equal 'se', light.stderr
    assert_equal 'se', kata.stderr
    assert_equal 39, light.status
    assert_equal 39, kata.status
  end

  private

  def create_kata(t = time_now)
    katas.new_kata(starter_manifest(t))
  end

  def starter_manifest(t = time_now)
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = t
    manifest
  end

end
