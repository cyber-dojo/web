# frozen_string_literal: true

require_relative 'id_pather'
require_relative 'manifest'
require_relative 'schema'
require_relative '../lib/id_generator'
require_relative '../../lib/oj_adapter'

class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def schema
    @schema ||= Schema.new(@externals, version)
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.exists?(groups_id_path(id))
  end

  # - - - - - - - - - - - - - - - - -

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

  def age
    katas.select(&:active?).map{ |kata| kata.age }.sort[-1] || 0
  end

  def manifest
    @manifest ||= Manifest.new(group.manifest(id))
  end

  private

  include IdPather
  include OjAdapter

  def version
    @version ||= begin
      # TODO: use @params[:version]
      path = groups_id_path(id, 'manifest.json')
      manifest_src = saver.read(path)
      json_parse(manifest_src)['version'] || 0
    end
  end

  AVATAR_INDEXES = (0..63).to_a

  def full?(kid)
    kid.nil?
  end

  def kata(kid)
    Kata.new(@externals, kid)
  end

  def group
    schema.group
  end

  def saver
    @externals.saver
  end

end
