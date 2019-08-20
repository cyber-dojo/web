require_relative 'runner'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def exists?
    saver.kata_exists?(id)
  end

  def group?
    group_id
  end

  def group
    if group?
      Group.new(@externals, group_id)
    else
      nil
    end
  end

  def avatar_index
    # if this kata is inside a group, the kata's index in the group
    # (which is used to determine its avatar), else nil
    manifest.group_index
  end

  def avatar_name
    if group?
      Avatars.names[avatar_index]
    else
      ''
    end
  end

  def run_tests(params, max_seconds = params[:max_seconds].to_i)
    Runner.new(@externals).run(self, params, max_seconds)
  end

  def events
    saver.kata_events(id).map.with_index do |h,index|
      Event.new(@externals, self, h, index)
    end
  end

  def lights
    events.select(&:light?)
  end

  def active?
    lights != []
  end

  def age
    created = Time.mktime(*manifest.created)
    (most_recent_event.time - created).to_i # in seconds
  end

  def files(sym = nil)
    most_recent_event.files(sym)
  end

  def stdout
    most_recent_event.stdout
  end

  def stderr
    most_recent_event.stderr
  end

  def status
    most_recent_event.status
  end

  def manifest
    @manifest ||= Manifest.new(saver.kata_manifest(id))
  end

  private

  def group_id
    # if this kata is inside a group, the group's id, else nil
    manifest.group_id
  end

  def most_recent_event
    events.last
  end

  def saver
    @externals.saver
  end

end
