require_relative 'id_pather'
require_relative 'manifest'
require_relative '../../lib/id_generator'

class Group

  def initialize(externals, id, v)
    @externals = externals
    @id = id
    @v = v
  end

  attr_reader :id

  def exists?
    IdGenerator.id?(id) &&
      saver.exists?(groups_id_path(id))
  end

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = (0..63).to_a.shuffle)
    kid = @v.group.join(id, indexes)
    if kid.nil?
      nil # full
    else
      kata(kid)
    end
  end

  def events
    @v.group.events(id)
  end

  def size
    katas.size
  end

  def empty?
    size == 0
  end

  def katas
    @v.group.joined(id).map{ |kid| kata(kid) }
  end

  def age
    katas.select(&:active?).map{ |kata| kata.age }.sort[-1] || 0
  end

  def manifest
    @manifest ||= Manifest.new(@v.group.manifest(id))
  end

  private

  include IdPather

  def kata(kid)
    Kata.new(@externals, kid, @v)
  end

  def saver
    @externals.saver
  end

end
