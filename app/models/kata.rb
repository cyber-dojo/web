# frozen_string_literal: true

require_relative 'avatars'
require_relative 'group'
require_relative 'id_pather'
require_relative 'manifest'
require_relative 'runner'
require_relative 'schema'
require_relative '../lib/id_generator'
require_relative '../../lib/oj_adapter'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def schema
    @schema ||= begin
      # TODO: use params[:version]
      path = katas_id_path(id, 'manifest.json')
      manifest_src = saver.read(path)
      version = json_parse(manifest_src)['version'] || 0
      Schema.new(externals, version)
    end
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.exists?(katas_id_path(id))
  end

  def group?
    group_id
  end

  def group
    if group?
      Group.new(externals, group_id)
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
    Runner.new(externals).run(self, params)
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

  include IdPather
  include OjAdapter

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
    externals.saver
  end

  attr_reader :externals

end
