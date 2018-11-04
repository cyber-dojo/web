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

  def group
    gid = manifest.group_id
    if gid
      Group.new(@externals, gid)
    else
      nil
    end
  end

  def avatar_name
    if group
      Avatars.names[manifest.group_index]
    else
      ''
    end
  end

  def run_tests(params)
    Runner.new(@externals, id).run(params)
  end

  def ran_tests(index, files, at, stdout, stderr, status, colour)
    saver.kata_ran_tests(id, index, files, at, stdout, stderr, status, colour)
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

  def files
    most_recent_event.files
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

  def lights
    events.select(&:light?)
  end

  def active?
    lights != []
  end

  def events
    saver.kata_events(id).map.with_index do |h,index|
      Event.new(@externals, self, h, index)
    end
  end

  def manifest
    @manifest ||= Manifest.new(saver.kata_manifest(id))
  end

  private

  def most_recent_event
    events.last
  end

  def saver
    @externals.saver
  end

end
