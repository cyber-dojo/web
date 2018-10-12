
class Groups

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Group.new(@externals, id)
  end

  def new_group(manifest)
    id = grouper.group_create(manifest)
    self[id]
  end

  private

  def grouper
    @externals.grouper
  end

end
