require_relative 'runner'
require_relative '../../lib/id_generator'

class Kata

  def initialize(externals, id, v)
    @externals = externals
    @id = id
    @v = v
  end

  attr_reader :id

  def exists?
    IdGenerator.id?(id) &&
      @v.kata.exists?(id)
  end

  def group?
    group_id
  end

  def group
    if group?
      Group.new(@externals, group_id, @v)
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

  def run_tests(params)
    Runner.new(@externals).run(self, params)
  end

  def ran_tests(index, files, at, duration, stdout, stderr, status, colour)
    @v.kata.ran_tests(id, index, files, at, duration, stdout, stderr, status, colour)
  end

  def events
    @v.kata.events(id).map.with_index do |h,index|
      Event.new(self, h, index)
    end
  end

  def event(index)
    @v.kata.event(id, index)
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
    @manifest ||= Manifest.new(@v.kata.manifest(id))
  end

  private

  def group_id
    # if this kata is inside a group, the group's id, else nil
    manifest.group_id
  end

  def most_recent_event
    events.last
  end

end
