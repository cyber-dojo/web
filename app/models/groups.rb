require_relative 'group'

class Groups

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Group.new(@externals, id)
  end

  def new_group(manifest)
    n = manifest['version'] || 0
    id = Version.new(@externals, n).group.create(manifest)
    self[id]
  end

end
