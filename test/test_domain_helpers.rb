
module TestDomainHelpers # mix-in

  module_function

  def dojo
    @dojo ||= Dojo.new(self)
  end

  def katas
    dojo.katas
  end

  def make_kata(hash = {})
    language = hash['language'] ||= default_language_name
    major_name = language.split('-')[0].strip
    minor_name = language.split('-')[1].strip
    exercise_name = hash['exercise'] || default_exercise_name
    manifest = starter.language_manifest(major_name, minor_name, exercise_name)
    if hash.key?('id')
      manifest['id'] = hash['id']
    end
    if hash.key?('now')
      manifest['created'] = hash['now']
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
