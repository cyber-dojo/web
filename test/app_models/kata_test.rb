require_relative 'app_models_test_base'
require_relative '../../app/services/saver_service'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'Fb9'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?

  test '760', %w(
  exists? is true,
  for a well-formed kata-id that exists,
  when saver is online
  ) do
    kata = create_kata
    assert katas[kata.id].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '761', %w(
  exists? is false,
  for a well-formed kata-id that does not exist,
  when saver is online
  ) do
    kata = create_kata
    refute katas['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '762', %w(
  exists? is false,
  for a malformed kata-id,
  when saver is online
  ) do
    refute katas[42].exists?, 'Integer'
    refute katas[nil].exists?, 'nil'
    refute katas[[]].exists?, '[]'
    refute katas[{}].exists?, '{}'
    refute katas[true].exists?, 'true'
    refute katas[''].exists?, 'length == 0'
    refute katas['12345'].exists?, 'length == 5'
    refute katas['12345i'].exists?, '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '763', %w(
  exists? raises,
  when kata-id is well-formed,
  and saver is offline
  ) do
    set_saver_class('SaverExceptionRaiser')
    assert_raises(SaverService::Error) {
      katas['123AbZ'].exists?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # ...

  test '862', %w(
  an individual kata is created from a well-formed manifest,
  is empty,
  and is not a member of a group,
  ) do
    kata = create_kata
    assert kata.exists?

    assert_equal 0, kata.age

    assert_nil kata.stdout
    assert_nil kata.stderr
    assert_nil kata.status

    refute kata.active?
    assert_equal [], kata.lights

    refute kata.group?
    refute_nil kata.group # NullObject pattern
    refute kata.group.exists?
    assert_nil kata.group.id
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

    assert kata.exists?

    assert_equal 0, kata.age

    assert_nil kata.stdout
    assert_nil kata.stderr
    assert_nil kata.status

    refute kata.active?
    assert_equal [], kata.lights

    assert kata.group?
    assert kata.group.exists?
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
    k = create_kata([2018,11,1, 9,13,56,6574])
    kata = Kata.new(self, kata_params(k))
    result = kata.run_tests
    stdout = result[0]['stdout']
    stderr = result[0]['stderr']
    status = result[0]['status']

    colour = 'red'
    now = [2018,11,1, 9,14,9,9154]
    kata.ran_tests(1, kata.files, now, duration, stdout, stderr, status, colour)
    assert_equal 13, kata.age
    assert kata.active?
    assert_equal 2, kata.events.size
    assert_equal 1, kata.lights.size
    light = kata.lights[0]
    assert_equal stdout, light.stdout
    assert_equal stderr, light.stderr
    assert_equal status, light.status
    assert_equal stdout, kata.stdout
    assert_equal stderr, kata.stderr
    assert_equal status, kata.status

    # event files can include pseudo output-files to help differ
    expected = kata.files.merge({
        'stdout' => light.stdout,
        'stderr' => light.stderr,
        'status' => { 'content' => light.status.to_s }
    })
    assert_equal expected, light.files(:with_output)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '865', %w(
  an event's manifest is ready to create a new kata from
  ) do
    kata = Kata.new(self, kata_params)
    result = kata.run_tests
    stdout = result[0]['stdout']
    stderr = result[0]['stderr']
    status = result[0]['status']
    colour = 'red'
    kata.ran_tests(1, kata.files, time_now, duration, stdout, stderr, status, colour)

    emanifest = kata.events[1].manifest
    refute_nil emanifest
    assert_nil emanifest['id']
    assert_nil emanifest['created']
    assert_equal kata.files, emanifest['visible_files']
    assert_equal kata.manifest.display_name, emanifest['display_name']
    assert_equal kata.manifest.image_name, emanifest['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '866', %w(
  kata.event(id,-1) is currently unused but ready for plumbing in
  ) do
    kata = Kata.new(self, kata_params)
    assert_equal kata.event(0), kata.event(-1)

    result = kata.run_tests
    stdout = result[0]['stdout']
    stderr = result[0]['stderr']
    status = result[0]['status']
    colour = 'red'
    kata.ran_tests(1, kata.files, time_now, duration, stdout, stderr, status, colour)
    assert_equal kata.event(1), kata.event(-1)
  end

end
