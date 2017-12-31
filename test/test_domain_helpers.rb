
module TestDomainHelpers # mix-in

  def in_kata(runner_choice, &block)
    display_name = {
        stateless: 'Python, unittest',
         stateful: 'C (gcc), assert',
       processful: 'Python, py.test'
    }[runner_choice]
    refute_nil display_name, runner_choice
    make_language_kata({ 'display_name' => display_name })
    begin
      assert_equal runner_choice.to_s, kata.runner_choice
      block.call
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def as_lion(&block)
    starting_files = kata.visible_files
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    begin
      block.call
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def make_language_kata(options = {})
    display_name = options['display_name'] || default_language_name
    exercise_name = options['exercise'] || default_exercise_name
    parts = display_name.split(',').map(&:strip)
    major_name = parts[0]
    minor_name = parts[1]
    manifest = starter.language_manifest(major_name, minor_name, exercise_name)
    manifest['id']      = (options['id']      || kata_id)
    manifest['created'] = (options['created'] || time_now)
    katas.create_kata(manifest)
  end

  def default_language_name(runner_choice = 'stateless')
    case runner_choice
    when 'stateful'  then 'C (gcc), assert'
    when 'stateless' then 'Python, unittest'
    end
  end

  def default_exercise_name
    'Fizz_Buzz'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def katas
    Katas.new(self)
  end

  def kata
    katas[kata_id]
  end

  def kata_id
    hex_test_id = ENV['CYBER_DOJO_TEST_ID']
    hex_test_id + ('0' * (10 - hex_test_id.length))
  end

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec]
  end

  def all_ids
    katas.map { |kata| kata.id }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def lion
    'lion'
  end

  def salmon
    'salmon'
  end

  def cheetah
    'cheetah'
  end

  def hippo
    'hippo'
  end

  def panda
    'panda'
  end

end
