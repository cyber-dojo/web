
module TestDomainHelpers # mix-in

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

  def default_language_name
    'C (gcc), assert'
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

  def all_katas_ids
    katas.map { |kata| kata.id }
  end

end
