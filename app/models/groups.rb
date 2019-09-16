require_relative 'version'
require_relative 'group'

class Groups

  def initialize(externals, n = 0)
    @externals = externals
    @v = Version.new(@externals, n)
  end

  def [](id)
    Group.new(@externals, id, @v)
  end

  def new_group(manifest)
    id = @v.group.create(manifest)
    self[id]
  end

end
