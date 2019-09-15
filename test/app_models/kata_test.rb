require_relative 'app_models_test_base'
require_relative '../../app/services/saver_exception'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'Fb9'
  end

  def hex_setup
    set_saver_class('SaverFake')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '8B1',
  'reserve id=999999 for non-persistent session' do
    @id_generator = Class.new do
      def initialize(*ids); @n = 0; @ids = ids; end
      def id; r = @ids[@n]; @n += 1; r; end
    end.new('999999',id_generator.id)
    kata = create_kata
    refute_equal '999999', kata.id
    @id_generator = nil
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '760',
  'a kata with an invalid id does not exist' do
    refute katas[42].exists?, 'Integer'
    refute katas[nil].exists?, 'nil'
    refute katas[[]].exists?, '[]'
    refute katas[{}].exists?, '{}'
    refute katas[true].exists?, 'true'
    refute katas[''].exists?, 'length == 0'
    refute katas['12345'].exists?, 'length == 5'
    refute katas['12345i'].exists?, '!Base58'
    refute katas['123AbZ'].exists?, 'no kata with that id'
  end

  test '761',
  'a kata with a valid id exists' do
    kata = create_kata
    assert katas[kata.id].exists?
  end

  test '762',
  'when saver is offline kata.exists? raises' do
    set_saver_class('SaverExceptionRaiser')
    assert_raises(SaverException) {
      katas['123AbZ'].exists?
    }
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

    assert_nil kata.stdout
    assert_nil kata.stderr
    assert_nil kata.status

    refute kata.active?
    assert_equal [], kata.lights

    refute kata.group?
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

    assert kata.exists?

    assert_equal 0, kata.age

    assert_nil kata.stdout
    assert_nil kata.stderr
    assert_nil kata.status

    refute kata.active?
    assert_equal [], kata.lights

    assert kata.group?
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
    kata = create_kata([2018,11,1, 9,13,56,6574])
    params = {
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:files_for(kata),
      hidden_filenames:'[]'
    }
    result = kata.run_tests(params)
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
        'status' => file(light.status.to_s)
    })
    assert_equal expected, light.files(:with_output)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '865', %w(
  an event's manifest is ready to create a new kata from
  ) do
    kata = create_kata([2018,11,1, 9,13,56,765])
    kmanifest = kata.manifest
    params = {
      image_name:kmanifest.image_name,
      max_seconds:kmanifest.max_seconds,
      file_content:files_for(kata),
      hidden_filenames:'[]'
    }
    result = kata.run_tests(params)
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
    assert_equal kmanifest.display_name, emanifest['display_name']
    assert_equal kmanifest.image_name, emanifest['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '866', %w(
  kata_v0.event(id,-1) is currently unused but ready for plumbing in
  ) do
    k = create_kata
    v = Kata_v0.new(self)
    assert_equal v.event(k.id,0), v.event(k.id, -1)
    kmanifest = k.manifest
    params = {
      image_name:kmanifest.image_name,
      max_seconds:kmanifest.max_seconds,
      file_content:files_for(k),
      hidden_filenames:'[]'
    }
    result = k.run_tests(params)
    stdout = result[0]['stdout']
    stderr = result[0]['stderr']
    status = result[0]['status']
    colour = 'red'
    k.ran_tests(1, k.files, time_now, duration, stdout, stderr, status, colour)
    assert_equal v.event(k.id,1), v.event(k.id, -1)
  end

  private

  def files_for(kata)
    kata.files(:with_output).map{ |filename,file|
      [filename, file['content']]
    }.to_h
  end

  def file(content)
    { 'content' => content }
  end

end
