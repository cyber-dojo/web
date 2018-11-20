
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
    all = event['files']
    if sym == :with_output
      all['stdout'] = stdout
      all['stderr'] = stderr
      all['status'] = status.to_s
    end
    all
  end

  def stdout
    event['stdout'] || no_content
  end

  def stderr
    event['stderr'] || no_content
  end

  def status
    event['status'] || no_content
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

  def manifest
    kata.manifest.to_json.merge({'visible_files' => files})
  end

  private

  def no_content
    { 'content' => '' }
  end

  def event
    @event ||= saver.kata_event(kata.id, index)
  end

  def saver
    @externals.saver
  end

end
