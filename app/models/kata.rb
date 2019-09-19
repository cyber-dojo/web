# frozen_string_literal: true

require_relative 'avatars'
require_relative 'group'
require_relative 'manifest'
require_relative 'runner'
require_relative 'schema'
require_relative 'version'
require_relative '../lib/id_generator'

class Kata

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def schema
    @schema ||= Schema.new(@externals, kata_version)
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.exists?(kata_id_path(id))
  end

  def group?
    group_id
  end

  def group
    if group?
      Group.new(@externals, @params.merge({id:group_id}))
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

  def run_tests
    Runner.new(@externals).run(@params)
  end

  def ran_tests(index, files, at, duration, stdout, stderr, status, colour)
    kata.ran_tests(id, index, files, at, duration, stdout, stderr, status, colour)
  end

  def events
    kata.events(id).map.with_index do |h,index|
      Event.new(self, h, index)
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

  def kata
    schema.kata
  end

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
