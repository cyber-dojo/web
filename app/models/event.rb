
class Event

  def initialize(externals, kata, hash, index)
    @externals = externals
    @kata = kata
    @hash = hash
    @index = index
  end

  def kata
    @kata
  end

  def files(sym = nil)
    all = manifest['files']
    if sym == :with_output
      all['stdout'] = stdout
      all['stderr'] = stderr
      all['status'] = status.to_s
    end
    all
  end

  def stdout
    manifest['stdout'] || ''
  end

  def stderr
    manifest['stderr'] || ''
  end

  def status
    manifest['status'] || ''
  end

  def time
    Time.mktime(*@hash['time'])
  end

  def index
    @index
  end

  def colour
    # '' unless light?
    (@hash['colour'] || '').to_sym
  end

  def light?
    colour.to_s != ''
  end

  private

  def manifest
    @manifest ||= saver.kata_event(kata.id, index)
  end

  def saver
    @externals.saver
  end

end
