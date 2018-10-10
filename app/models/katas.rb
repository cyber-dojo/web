
class Katas

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest, files)
    id = singler.kata_create(manifest, files)
    runner.kata_new(manifest['image_name'], id, files)
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
