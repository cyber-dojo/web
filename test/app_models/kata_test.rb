require_relative './app_models_test_base'
require_relative './../app_lib/delta_maker'

class KataTest < AppModelsTestBase

  def setup
    super
    set_storer_class('FakeStorer')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '677A57',
  'id reads back as set' do
    id = unique_id
    kata = make_kata({ id:id })
    assert_equal id, kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '66C9AE',
  'when kata has no avatars',
  'then it is not active',
  'and its age is zero' do
    kata = make_kata
    refute kata.active?
    assert_equal 0, kata.age
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B9340E',
  "when kata's avatars have 0 traffic-lights",
  'then it is not active',
  'and its age is zero' do
    kata = make_kata
    kata.start_avatar(['hippo'])
    kata.start_avatar(['lion'])
    refute kata.active?
    assert_equal 0, kata.age
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2CDD3',
  'when kata has at least one avatar with 1 or more traffic-lights',
  'then kata is active',
  'and age is from earliest traffic-light to now' do
    kata = make_kata

    hippo = kata.start_avatar(['hippo'])
    first_time = [2014, 2, 15, 8, 54, 6]
    DeltaMaker.new(hippo).run_test(first_time)

    lion = kata.start_avatar(['lion'])
    second_time = [2014, 2, 15, 8, 54, 34]
    DeltaMaker.new(lion).run_test(second_time)

    assert kata.active?
    now = first_time
    now[seconds_slot = -1] += 17
    assert_equal 17, kata.age(now)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '78A205',
  'make_kata with default-now uses time-now' do
    now = Time.now
    kata = make_kata
    created = Time.mktime(*kata.created)
    past = Time.mktime(now.year, now.month, now.day, now.hour, now.min, now.sec)
    diff = created - past
    assert 0 <= diff && diff <= 1, "created=#{created}, past=#{past}, diff=#{past}"
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6AF51F',
  'kata properties are union of language properties and exercise instruction' do
    id = unique_id
    now = [2014, 7, 17, 21, 15, 45]
    hash = {
      id: id,
      now: now,
      language: 'Java-JUnit',
      exercise: 'Fizz_Buzz',
    }
    java_junit = languages[hash[:language]]
    fizz_buzz  = exercises[hash[:exercise]]
    kata = make_kata(hash)
    assert_equal id, kata.id
    assert_equal Time.mktime(*now), kata.created
    assert_equal java_junit.image_name, kata.image_name
    assert_equal java_junit.tab_size, kata.tab_size
    assert_equal java_junit.display_name, kata.display_name
    assert_equal java_junit.filename_extension, kata.filename_extension
    assert_equal java_junit.progress_regexs, kata.progress_regexs
    assert_equal java_junit.highlight_filenames, kata.highlight_filenames
    assert_equal java_junit.lowlight_filenames, kata.lowlight_filenames
    assert_equal java_junit.name, kata.language
    assert_equal fizz_buzz.name, kata.exercise
    assert_equal fizz_buzz.text, kata.visible_files['instructions']
    assert_equal '', kata.visible_files['output']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0A5632',
  'started_avatars is initially empty array' do
    @kata = make_kata
    assert_equal [], avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8BDB48',
  'start_avatar with name that is not a known avatar is nil' do
    kata = make_kata
    assert_nil kata.start_avatar(['sellotape'])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '139C43',
  'start_avatar with specific name succeeds when avatar has not yet started' do
    @kata = make_kata
    hippo = @kata.start_avatar(['hippo'])
    refute_nil hippo
    assert_equal 'hippo', hippo.name
    assert_equal ['hippo'], avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A653FA',
  'start_avatar with specific name is nil when avatar has already started' do
    kata = make_kata
    kata.start_avatar(['hippo'])
    avatar = kata.start_avatar(['hippo'])
    assert_nil avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4C66C8',
  'start_avatar with specific names tries them in order' do
    @kata = make_kata
    names = %w(cheetah lion panda)

    cheetah = @kata.start_avatar(names)
    refute_nil cheetah
    assert_equal 'cheetah', cheetah.name
    assert_equal ['cheetah'], avatars_names

    lion = @kata.start_avatar(names)
    refute_nil lion
    assert_equal 'lion', lion.name
    assert_equal ['cheetah','lion'], avatars_names

    panda = @kata.start_avatar(names)
    refute_nil panda
    assert_equal 'panda', panda.name
    assert_equal ['cheetah','lion','panda'], avatars_names

    assert_nil @kata.start_avatar(names)
    assert_equal names.sort, avatars_names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '08141A',
  'start_avatar succeeds once for each avatar name then its full and is nil' do
    kata = make_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    assert_nil kata.start_avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FE8A3D',
  'start_avatar starts avatars in random order' do
    kata = make_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    refute_equal created, created.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1CD446',
  'red_amber_green(nil) returns the lamda source' do
    kata = make_kata
    expected = [
      "lambda { |output|",
      "  return :red   if /(.*)Assertion(.*)failed./.match(output)",
      "  return :green if /(All|\\d*) tests passed/.match(output)",
      "  return :amber",
      "}"
    ]
    assert_equal expected, kata.red_amber_green(nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E391FE',
  'after start-points volume re-architecture, initial colour is red/amber/green' +
  ' determined by lambda held in kata manifest' do
    hash = {
      language: 'C#-Moq',
      exercise: 'Fizz_Buzz',
    }
    kata = make_kata(hash)
    json = storer.kata_manifest(kata.id)
    refute_nil json['red_amber_green']
    assert_equal 'red'  , kata.red_amber_green('Errors and Failures:'), :red
    assert_equal 'amber', kata.red_amber_green('sdfsdfsdf'), :amber
    assert_equal 'green', kata.red_amber_green('Tests run: 3, Errors: 0, Failures: 0'), :green
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5177CC',
  'before start-points volume re-architecture' +
  ' initial colour is red/amber/green' +
  ' determined by OutputColour.of()' do
    hash = {
      language: 'C#-Moq',
      exercise: 'Fizz_Buzz',
    }
    kata = make_kata(hash)

    json = storer.kata_manifest(kata.id)
    json.delete('red_amber_green')
    json['unit_test_framework'] = 'nunit'
    storer.kata_dir(kata.id).write_json('manifest.json', json)

    assert_nil kata.red_amber_green(nil)
    assert_equal 'red'  , kata.red_amber_green('Errors and Failures:'), :red
    assert_equal 'amber', kata.red_amber_green('sdfsdfsdf'), :amber
    assert_equal 'green', kata.red_amber_green('Tests run: 3, Errors: 0, Failures: 0'), :green
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B80712',
  'when the start_point the kata was created from is no longer loaded' +
  " the kata's properties are all still available" do
    hash = {
      language: 'C#-Moq',
      exercise: 'Fizz_Buzz',
    }
    kata = make_kata(hash)
    refute_nil kata

    property_names = %w(
      display_name
      image_name
      filename_extension
      progress_regexs
      highlight_filenames
      lowlight_filenames
    )

    json = storer.kata_manifest(kata.id)
    property_names.each { |property_name| json.delete(property_name) }
    storer.kata_dir(kata.id).write_json('manifest.json', json)

    property_names.each { |property_name| refute_nil kata.send(property_name) }
    assert_equal 'C#, Moq', kata.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def avatars_names
    @kata.avatars.map(&:name).sort
  end

end
