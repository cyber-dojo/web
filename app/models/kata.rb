# frozen_string_literal: true

require_relative 'avatars'
require_relative 'group'
require_relative 'manifest'
require_relative 'runner'
require_relative 'schema'
require_relative 'version'

class Kata

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.run(saver.dir_exists_command(kata_id_path(id)))
  end

  # - - - - - - - - - - - - - - - - -

  def schema
    @schema ||= Schema.new(@externals, kata_version)
  end

  def group?
    group_id
  end

  def group
    # NullObject pattern if group_id.nil?
    Group.new(@externals, @params.merge({id:group_id}))
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

  # - - - - - - - - - - - - - - - - -

  def theme=(value)
    #STDOUT.puts("models/kata/#{id} theme=(#{value})")
    #STDOUT.flush
  end

  def theme
    'dark' # default
  end

  # - - - - - - - - - - - - - - - - -

  def colour=(value)
    #STDOUT.puts("models/kata/#{id} colour=(#{value})")
    #STDOUT.flush
  end

  def colour
    'on' # default
  end

  # - - - - - - - - - - - - - - - - -

  def diff_info(was_index, now_index)
    m,e,was,now = kata.diff_info(id, was_index, now_index)
    was_files = diff_files(was)
    now_files = diff_files(now)
    events = e.map.with_index do |h,index|
      h['index'] ||= index
      Event.new(self, h)
    end
    [m,events,was_files,now_files]
  end

  # - - - - - - - - - - - - - - - - -

  def tipper_info(was_index, now_index)
    e,was_files,now_files = kata.tipper_info(id, was_index, now_index)
    events = e.map.with_index do |h,index|
      h['index'] ||= index
      Event.new(self, h)
    end
    [events,plain(was_files),plain(now_files)]
  end

  # - - - - - - - - - - - - - - - - -

  def run_tests
    Runner.new(@externals).run(@params)
  end

  def ran_tests(index, files, at, duration, stdout, stderr, status, colour, predicted='none')
    kata.ran_tests(id, index, files, at, duration, stdout, stderr, status, colour, predicted)
  end

  def events
    kata.events(id).map.with_index do |h,index|
      h['index'] ||= index
      Event.new(self, h)
    end
  end

  def event(index)
    kata.event(id, index)
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
    @manifest ||= Manifest.new(kata.manifest(id))
  end

  private

  include Version

  def plain(files)
    files.map{ |filename,file| [filename, file['content']] }.to_h
  end

  def diff_files(h)
    files = plain(h['files'])
    files['stdout'] = content(h, 'stdout')
    files['stderr'] = content(h, 'stderr')
    files['status'] = (h['status'] || '').to_s
    files
  end

  def content(h,k)
    if h.has_key?(k)
      h[k]['content']
    else
      ''
    end
  end

  # - - - - - - - - - - - - - - - - -

  def group_id
    manifest.group_id # nil if not in a group
  end

  def kata
    schema.kata
  end

  def most_recent_event
    # This should be quicker than event(-1)
    events.last
  end

  def saver
    @externals.saver
  end

end
