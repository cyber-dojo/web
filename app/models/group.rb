require_relative 'id_pather'
require_relative 'manifest'
require_relative '../../lib/id_generator'
require_relative '../../lib/oj_adapter'

class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def version
    @version ||= begin
      # TODO: params[:version]
      path = groups_id_path(id, 'manifest.json')
      manifest_src = saver.read(path)
      n = json_parse(manifest_src)['version'] || 0
      Version.new(@externals, n)
    end
  end

  def exists?
    IdGenerator.id?(id) &&
      saver.exists?(groups_id_path(id))
  end

  # - - - - - - - - - - - - - - - - -

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = (0..63).to_a.shuffle)
    kid = group.join(id, indexes)
    if kid.nil?
      nil # full
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

  def kata(kid)
    Kata.new(@externals, kid)
  end

  def group
    version.group
  end

  def saver
    @externals.saver
  end

end
