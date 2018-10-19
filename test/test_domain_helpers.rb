
module TestDomainHelpers # mix-in

  def in_kata(runner_choice = :stateless, &block)
    display_name = {
        stateless: 'Ruby, MiniTest',
         stateful: 'Ruby, RSpec',
       processful: 'Ruby, Test::Unit'
    }[runner_choice]
    refute_nil display_name, runner_choice
    kata = make_language_kata({ 'display_name' => display_name })
    begin
      block.call(kata)
    ensure
      runner.kata_old(kata.manifest.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - -

  def wolf
    kata.avatars['wolf']
  end

  def lion
    kata.avatars['lion']
  end

  # - - - - - - - - - - - - - - - -

  def make_language_kata(options = {})
    display_name = options['display_name'] || default_language_name
    exercise_name = options['exercise'] || default_exercise_name
    manifest = starter.language_manifest(display_name, exercise_name)
    manifest['created'] = (options['created'] || time_now)
    katas.new_kata(manifest)
  end

  def default_language_name
    'Ruby, MiniTest'
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
    ENV['CYBER_DOJO_TEST_ID'][0..5]
  end

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec]
  end

end
