
class Tag

  def initialize(externals, kata, hash)
    @externals = externals
    @kata = kata
    @hash = hash
  end

  def kata
    @kata
  end

  def visible_files
    @manifest ||= singler.tag_visible_files(kata.id, number)
  end

  def time
    Time.mktime(*@hash['time'])
  end

  def colour
    # Very early dojos used outcome
    (@hash['colour'] || @hash['outcome'] || '').to_sym
  end

  def number
    @hash['number']
  end

  # - - - - - - - -

  def output
    # Used in dashboard's recent_progress
    # Very early dojos didn't store output in initial tag 0
    visible_files['output'] || ''
  end

  def light?
    colour.to_s != ''
  end

  private

  def singler
    @externals.singler
  end

end
