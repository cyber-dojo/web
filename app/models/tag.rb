
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
    manifest['files']
  end

  def stdout
    manifest['stdout']
  end

  def stderr
    manifest['stderr']
  end

  def status
    manifest['status']
  end

  # - - - - - - - -

  def time
    Time.mktime(*@hash['time'])
  end

  def colour
    # colour.nil? unless light?
    (@hash['colour'] || '').to_sym
  end

  def number
    @hash['number']
  end

  # - - - - - - - -

  def light?
    colour.to_s != ''
  end

  private

  def singler
    @externals.singler
  end

  def manifest
    @manifest ||= singler.tag(kata.id, number)
  end

end
