
class Groups

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Group.new(@externals, id)
  end

  def new_group(manifest)
    id = saver.group_create(manifest)
    self[id]
  end

  private

  def saver
    @externals.saver
  end

end
