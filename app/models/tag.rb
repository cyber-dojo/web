
class Tag

  def initialize(externals, kata, hash)
    @externals = externals
    @kata = kata
    @hash = hash
  end

  def kata
    @kata
  end

  def files
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

  def manifest
    @manifest ||= saver.kata_event(kata.id, number)
  end

  def saver
    @externals.saver
  end

end
