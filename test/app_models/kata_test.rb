require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    '677C0C'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A56', %w(
  default to using test-hex-id as kata-id ) do
    in_kata {
      assert kata.id.start_with?('677C0CA56')
    }
  end

  test 'A57', %w(
  short_id is the first 6 digits of the id which statistically is enough for uniqueness ) do
    in_kata {
      assert_equal kata.id[0..5], kata.short_id
    }
  end

  test 'A58', %w(
  phonetic_short_id is phonetic wording of short_id separated by hyphens ) do
    expected = %w( six seven seven CHARLIE zero CHARLIE ).join('-')
    assert_equal expected, kata.phonetic_short_id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # manifest properties
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '51F', %w(
  kata properties are union of language properties and exercise instruction ) do
    in_kata {
      assert_equal kata_id, kata.id
      assert_equal 'stateless', kata.manifest.runner_choice
      assert_equal 'cyberdojofoundation/ruby_mini_test', kata.manifest.image_name
      assert_equal 2, kata.manifest.tab_size

      assert_equal 'Ruby, MiniTest', kata.manifest.display_name
      assert_equal ['.rb'], kata.manifest.filename_extension
      assert_equal [], kata.manifest.progress_regexs
      assert_equal [], kata.manifest.highlight_filenames
      assert_equal 'Fizz_Buzz', kata.manifest.exercise
      assert_equal 10, kata.manifest.max_seconds
      assert_equal '', kata.visible_files['output']
      assert kata.visible_files['instructions'].start_with?('Write a program that prints the numbers from 1 to 100')
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5A7', %w(
  when id is invalid
  then exists? is false  ) do
    refute katas[nil].exists?
  end

  test '5A8', %w(
  when id is valid
  but kata has not been setup
  then exists? false ) do
    refute katas[kata_id].exists?
  end

  test '5A9', %w(
  when id is valid
  and the kata has been setup
  then exists? is true  ) do
    in_kata {
      assert kata.exists?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # active?
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9AE', %w(
  when kata has no avatars
  then it is not active ) do
    in_kata {
      refute kata.active?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '40E', %w(
  when kata's avatars have no traffic-lights
  then it is not active ) do
    in_kata {
      as(:hippo) {}
      as(:lion) {}
      refute kata.active?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD3', %w(
  when kata has at least one avatar with 1 or more traffic-lights
  then kata is active ) do
    in_kata {
      as(:wolf) {
        first_time = [2014,2,15, 8,54,6]
        DeltaMaker.new(wolf).run_test(first_time)
      }
      as(:lion) {
        second_time = [2014,2,15, 8,54,34]
        DeltaMaker.new(lion).run_test(second_time)
      }
      assert kata.active?
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # age
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD4', %w(
  when a kata has no avatars
  then its age is zero seconds ) do
    in_kata {
      assert_equal 0, kata.age
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD5', %w(
  when a kata has avatars
  but none of them have any traffic-lights
  then its age is zero seconds ) do
    in_kata {
      as(:kingfisher) {}
      as(:parrot) {}
      assert_equal 0, kata.age
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD6', %w(
  when a kata has one avatar
  with one traffic-light
  then its age is zero seconds ) do
    in_kata {
      as(:lion) {
        DeltaMaker.new(lion).run_test([2014,2,15, 8,54,6])
        assert_equal 0, kata.age
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD7', %w(
  when a kata has two avatars
  and they both have one one traffic-light
  with exactly the same time-stamp
  then its age is zero ) do
    in_kata {
      time = [2018,1,2, 8,54,6]
      as(:wolf) {
        DeltaMaker.new(wolf).run_test(time)
      }
      as(:lion) {
        DeltaMaker.new(lion).run_test(time)
      }
      assert_equal 0, kata.age
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD8', %w(
  when a kata has one avatar
  and it has two traffic-lights
  then its age is the time difference ) do
    in_kata {
      as(:lion) {
        first_time       = [2018,1,3, 8,54,6]
        one_second_later = [2018,1,3, 8,54,7]
        maker = DeltaMaker.new(lion)
        maker.run_test(first_time)
        maker.run_test(one_second_later)
        assert_equal 1, kata.age
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DD9', %w(
  when a katas has two avatars
  each with one traffic-light
  then its age is the time difference ) do
    in_kata {
      as(:lion) {
        lion_time = [2018,1,2, 8,13,56]
        DeltaMaker.new(lion).run_test(lion_time)
      }
      as(:wolf) {
        wolf_time = [2018,1,2, 8,14,19]
        DeltaMaker.new(wolf).run_test(wolf_time)
      }
      assert_equal (4+19), kata.age
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DDA', %w(
  when a kata has two avatars
  each with several traffic-light
  then its age is the time difference
  between the earliest and latest traffic-light ) do
    in_kata {
      as(:wolf) {
        DeltaMaker.new(wolf).run_test([2018,1,2, 8,13,56]) # earliest
        DeltaMaker.new(wolf).run_test([2018,1,2, 8,14,23])
      }
      as(:lion) {
        DeltaMaker.new(lion).run_test([2018,1,2, 8,14,19])
        DeltaMaker.new(lion).run_test([2018,1,2, 8,15,45]) # latest
      }
      assert_equal (4+60+45), kata.age
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # created
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '205', %w(
  new kata's with default created-property uses time-now ) do
    in_kata {
      created = Time.mktime(*kata.created)
      now = Time.now
      past = Time.mktime(now.year, now.month, now.day, now.hour, now.min, now.sec)
      diff = created - past
      assert 0 <= diff && diff <= 1, "created=#{created}, past=#{past}, diff=#{past}"
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # avatar_start
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '632', %w(
  avatars_started is initially empty array ) do
    in_kata {
      assert_equal [], kata.avatars.names
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B48', %w(
  avatar_start() with name that is not a known avatar is nil ) do
    in_kata {
      assert_nil kata.avatar_start(['sellotape'])
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C43', %w(
  avatar_start() with specific name succeeds when avatar has not yet started ) do
    in_kata {
      as(:hippo) {
        hippo = kata.avatars['hippo']
        refute_nil hippo
        assert_equal 'hippo', hippo.name
        assert_equal ['hippo'], kata.avatars.names
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3FA', %w(
  avatar_start() with specific name is nil when avatar has already started ) do
    in_kata {
      as(:hippo) {
        assert_nil kata.avatar_start(['hippo'])
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6C8', %w(
  avatar_start() with specific names tries them in order ) do
    in_kata {
      names = %w(cheetah lion panda)

      cheetah = kata.avatar_start(names)
      refute_nil cheetah
      assert_equal 'cheetah', cheetah.name
      assert_equal ['cheetah'], kata.avatars.names

      lion = kata.avatar_start(names)
      refute_nil lion
      assert_equal 'lion', lion.name
      assert_equal ['cheetah','lion'], kata.avatars.names

      panda = kata.avatar_start(names)
      refute_nil panda
      assert_equal 'panda', panda.name
      assert_equal ['cheetah','lion','panda'], kata.avatars.names

      assert_nil kata.avatar_start(names)
      assert_equal names.sort, kata.avatars.names
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '41A', %w(
  avatar_start() succeeds once for each avatar-name then is full ) do
    in_kata {
      created = []
      Avatars.names.length.times do
        avatar = kata.avatar_start
        refute_nil avatar
        created << avatar.name
      end
      assert_equal Avatars.names.sort, created.sort
      assert_nil kata.avatar_start
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4DA', %w(
  filename_extension for single string becomes an array ) do
    set_starter_class('StarterService')
    kata = make_language_kata({ 'display_name' => 'Ruby, MiniTest' })
    assert_equal 'stateless', kata.runner_choice # no need to call kata_old()
    assert_equal [ ".rb" ], kata.filename_extension
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4DB', %w(
  filename_extension for an array stays an array ) do
    set_starter_class('StarterService')
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    assert_equal 'stateless', kata.runner_choice # no need to call kata_old()
    assert_equal [ ".c", ".h" ], kata.filename_extension
  end

end
