
module TestDomainHelpers # mix-in

  def katas
    Katas.new(self)
  end

  module_function

  def make_kata(properties = {})
    language = properties['language'] ||= default_language_name
    major_name = language.split('-')[0].strip
    minor_name = language.split('-')[1].strip
    exercise_name = properties['exercise'] || default_exercise_name
    manifest = starter.language_manifest(major_name, minor_name, exercise_name)
    if properties.key?('id')
      manifest['id'] = properties['id']
    end
    if properties.key?('created')
      manifest['created'] = properties['created']
    end
    katas.create_kata(manifest)
  end

  def unique_id
    hex_chars = '0123456789ABCDEF'.split(//)
    Array.new(10) { hex_chars.sample }.shuffle.join
  end

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec]
  end

  def default_language_name
    # The first to be Alpine'd and so the smallest
    'C (gcc)-assert'
  end

  def default_exercise_name
    'Fizz_Buzz'
  end

  def cdf
    'cyberdojofoundation'
  end

end
