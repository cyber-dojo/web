
class Groups

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Group.new(@externals, id)
  end

  def new_group(manifest, files)
    id = grouper.group_create(manifest, files)
    self[id]
  end

  private

  def grouper
    @externals.grouper
  end

end
