
class Katas

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest)
    id = singler.kata_create(manifest)
    runner.kata_new(manifest['image_name'], id, manifest['visible_files'])
    self[id]
  end

  private

  def singler
    @externals.singler
  end

  def runner
    @externals.runner
  end

end
