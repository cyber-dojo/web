require_relative 'group_v0'

class Groups

  def initialize(externals)
    @v = Group_v0.new(externals)
    @externals = externals
  end

  def [](id)
    Group.new(@externals, id)
  end

  def new_group(manifest)
    id = @v.create(manifest)
    self[id]
  end

end
