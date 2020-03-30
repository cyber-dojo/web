# frozen_string_literal: true

class Event

  def initialize(kata, hash)
    @kata = kata
    @hash = hash
    @index = index
  end

  attr_reader :kata

  def index
    @hash['index']
  end

  def files(sym = nil)
    all = event['files']
    if sym === :with_output
      all['stdout'] = stdout || content('')
      all['stderr'] = stderr || content('')
      all['status'] = content((status || '').to_s)
    end
    all
  end

  def stdout
    event['stdout']
  end

  def stderr
    event['stderr']
  end

  def status
    event['status']
  end

  def time
    Time.mktime(*@hash['time'])
  end

  def predicted
    @hash['predicted'] || 'none'
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

  def content(s)
    { 'content' => s }
  end

  def event
    @event ||= kata.event(index)
  end

end
