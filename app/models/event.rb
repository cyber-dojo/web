# frozen_string_literal: true

class Event

  def initialize(kata, summary)
    @kata = kata
    @summary = summary
  end

  attr_reader :kata

  # - - - - - - - - - - - - - - - - - - - -
  # core properties

  def files
    event['files']
  end

  def stdout
    event['stdout'] || content('')
  end

  def stderr
    event['stderr'] || content('')
  end

  def status
    event['status']
  end

  # - - - - - - - - - - - - - - - - - - - -
  # summary properties

  def index
    @summary['index']
  end

  def time
    Time.mktime(*@summary['time'])
  end

  def predicted
    @summary['predicted'] || 'none'
  end

  def colour
    # '' unless light?
    (@summary['colour'] || '').to_sym
  end

  def checkout
    @summary['checkout']
  end

  def revert
    @summary['revert']
  end

  def light?
    colour.to_s != ''
  end

  private

  def content(s)
    { 'content' => s }
  end

  def event
    @event ||= kata.event(index)
  end

end
