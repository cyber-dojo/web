require_relative 'kata_v0'
require_relative 'kata_v1'
require_relative 'group_v0'
require_relative 'group_v1'
require_relative 'id_pather'
require_relative '../../lib/oj_adapter'

class Version

  def initialize(externals, n)
    @externals = externals
    @n = n
    if n === 0
      @group ||= Group_v0.new(@externals)
      @kata  ||= Kata_v0.new(@externals)
    end
    if n === 1
      @group ||= Group_v1.new(@externals)
      @kata  ||= Kata_v1.new(@externals)
    end
  end

  attr_reader :group, :kata

  def number
    @n
  end

  def self.for_group(externals, gid)
    path = groups_id_path(gid, manifest_filename)
    version(externals, path)
  end

  def self.for_kata(externals, kid)
    path = katas_id_path(kid, manifest_filename)
    version(externals, path)
  end

  private

  extend IdPather
  extend OjAdapter

  def self.version(externals, path)
    manifest_src = externals.saver.read(path)
    json_parse(manifest_src)['version'] || 0
  end

  def self.manifest_filename
    'manifest.json'
  end

end
