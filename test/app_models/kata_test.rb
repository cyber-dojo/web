require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    '677C0C'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A56', %w(
  make_language_kata() helper defaults to using test hex-id as kata-id ) do
    kata = make_language_kata
    assert_equal kata_id, kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5A7', %w( exists? false when id is valid but kata has not been made ) do
    refute katas[kata_id].exists?
  end

  test '5A8', %w( exists? is false when id is invalid ) do
    refute katas[nil].exists?
  end

  test '5A9', %w( exists? is true when id is valid and katas has been made ) do
    kata = make_language_kata
    assert kata.exists?
  end


  test '9AE', %w( when kata has no avatars, then it is not active ) do
    kata = make_language_kata
    refute kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8C8', %w(
  major_name,minor_name are comma-separated parts of display_name ) do
    kata = make_language_kata({ 'display_name' => 'Python, unittest' })
    assert_equal 'Python', kata.major_name
    assert_equal 'unittest', kata.minor_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '40E', %w(
  when kata's avatars have 0 traffic-lights
  then it is not active ) do
    kata = make_language_kata
    kata.start_avatar(['hippo'])
    kata.start_avatar(['lion'])
    refute kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD3', %w(
  when kata has at least one avatar with 1 or more traffic-lights
  then kata is active ) do
    kata = make_language_kata

    hippo = kata.start_avatar(['hippo'])
    first_time = [2014,2,15, 8,54,6]
    DeltaMaker.new(hippo).run_test(first_time)

    lion = kata.start_avatar(['lion'])
    second_time = [2014,2,15, 8,54,34]
    DeltaMaker.new(lion).run_test(second_time)

    assert kata.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '205', %w(
  make_language_kata with default created-property uses time-now ) do
    now = Time.now
    kata = make_language_kata
    created = Time.mktime(*kata.created)
    past = Time.mktime(now.year, now.month, now.day, now.hour, now.min, now.sec)
    diff = created - past
    assert 0 <= diff && diff <= 1, "created=#{created}, past=#{past}, diff=#{past}"
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '51F', %w(
  kata properties are union of language properties and exercise instruction ) do
    created = [2017,12,21, 10,40,24]
    options = {
      'created'      => created,
      'display_name' => 'Python, unittest',
      'exercise'     => 'Fizz_Buzz',
    }
    kata = make_language_kata(options)

    assert_equal kata_id, kata.id
    assert_equal Time.mktime(*created), kata.created
    assert_equal 'stateless', kata.runner_choice
    assert_equal 'cyberdojofoundation/python_unittest', kata.image_name
    assert_equal 3, kata.tab_size
    assert_equal 'Python, unittest', kata.display_name
    assert_equal '.py', kata.filename_extension

    assert_equal ['FAILED \\(failures=\\d+\\)', 'OK'], kata.progress_regexs
    assert_equal ['test_hiker.py'], kata.highlight_filenames
    assert_equal ['hiker.py','cyber-dojo.sh','output','instructions'], kata.lowlight_filenames
    assert_equal 'Python', kata.major_name
    assert_equal 'unittest', kata.minor_name
    assert_equal 'Fizz_Buzz', kata.exercise
    assert_equal 11, kata.max_seconds
    assert_equal 'Fizz_Buzz', kata.visible_files['instructions']
    assert_equal '', kata.visible_files['output']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '632', %w(
  started_avatars is initially empty array ) do
    kata = make_language_kata
    assert_equal [], kata.avatars.names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B48', %w(
  start_avatar() with name that is not a known avatar is nil ) do
    kata = make_language_kata
    assert_nil kata.start_avatar(['sellotape'])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C43', %w(
  start_avatar() with specific name succeeds when avatar has not yet started ) do
    kata = make_language_kata
    hippo = kata.start_avatar(['hippo'])
    refute_nil hippo
    assert_equal 'hippo', hippo.name
    assert_equal ['hippo'], kata.avatars.names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3FA', %w(
  start_avatar() with specific name is nil when avatar has already started ) do
    kata = make_language_kata
    kata.start_avatar(['hippo'])
    avatar = kata.start_avatar(['hippo'])
    assert_nil avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6C8', %w(
  start_avatar() with specific names tries them in order ) do
    kata = make_language_kata
    names = %w(cheetah lion panda)

    cheetah = kata.start_avatar(names)
    refute_nil cheetah
    assert_equal 'cheetah', cheetah.name
    assert_equal ['cheetah'], kata.avatars.names

    lion = kata.start_avatar(names)
    refute_nil lion
    assert_equal 'lion', lion.name
    assert_equal ['cheetah','lion'], kata.avatars.names

    panda = kata.start_avatar(names)
    refute_nil panda
    assert_equal 'panda', panda.name
    assert_equal ['cheetah','lion','panda'], kata.avatars.names

    assert_nil kata.start_avatar(names)
    assert_equal names.sort, kata.avatars.names
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '41A', %w(
  start_avatar() succeeds once for each avatar-name then is full ) do
    kata = make_language_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    assert_nil kata.start_avatar
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A3D', %w(
  start_avatar() starts avatars in random order ) do
    kata = make_language_kata
    created = []
    Avatars.names.length.times do
      avatar = kata.start_avatar
      refute_nil avatar
      created << avatar.name
    end
    assert_equal Avatars.names.sort, created.sort
    refute_equal created, created.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D61', %w(
  when collector has collected the runner containers/volumes
  then start_avatar() seamlessly resurrects ) do
    set_runner_class('RunnerService')
    set_starter_class('StarterService')
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    assert kata.runner_choice == 'stateful'
    runner.kata_old(kata.image_name, kata.id)
    begin
      avatar = kata.start_avatar
      runner.avatar_old(kata.image_name, kata.id, avatar.name)
      refute_nil avatar
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

end
