# frozen_string_literal: true

require_relative 'manifest'
require_relative 'schema'
require_relative 'version'

class Group

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.run(saver.dir_exists_command(group_id_path(id)))
  end

  # - - - - - - - - - - - - - - - - -

  def schema
    @schema ||= Schema.new(@externals, group_version)
  end

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = AVATAR_INDEXES.shuffle)
    kid = group.join(id, indexes)
    if full?(kid)
      nil
    else
      kata(kid)
    end
  end

  def events
    group.events(id)
  end

  def size
    katas.size
  end

  def empty?
    size === 0
  end

  def katas
    group.joined(id).map{ |kid| kata(kid) }
  end

  def age(e = events)
    e.map{|kata_id,o| age_of(o['events']) }.max || 0
  end

  def manifest
    @manifest ||= Manifest.new(group.manifest(id))
  end

  private

  include Version

  AVATAR_INDEXES = (0..63).to_a

  def full?(kid)
    kid.nil?
  end

  def kata(kid)
    Kata.new(@externals, @params.merge({id:kid}))
  end

  def age_of(o)
    seconds_diff(o[0]['time'], o[-1]['time'])
  end

  def seconds_diff(from, to)
    (Time.mktime(*to) - Time.mktime(*from)).to_i
  end

  def group
    schema.group
  end

  def saver
    @externals.saver
  end

end
