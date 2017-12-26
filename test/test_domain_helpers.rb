
module TestDomainHelpers # mix-in

  def katas
    Katas.new(self)
  end

  module_function

  def make_language_kata(options = {})
    display_name = options['display_name'] || default_display_name
    exercise_name = options['exercise'] || default_exercise_name
    parts = display_name.split(',').map(&:strip)
    major_name = parts[0]
    minor_name = parts[1]
    manifest = starter.language_manifest(major_name, minor_name, exercise_name)
    manifest['id']      = (options['id']      || unique_id)
    manifest['created'] = (options['created'] || time_now)
    katas.create_kata(manifest)
  end

  def default_display_name
    'C (gcc), assert'
  end

  def default_exercise_name
    'Fizz_Buzz'
  end

  def unique_id
    hex_chars = '0123456789ABCDEF'.split(//)
    Array.new(10) { hex_chars.sample }.shuffle.join
  end

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec]
  end

  def cdf
    'cyberdojofoundation'
  end

end
