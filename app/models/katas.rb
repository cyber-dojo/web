
class Katas

  def initialize(externals)
    @externals = externals
  end

  # queries

  def [](id)
    Kata.new(@externals, id)
  end

  # modifier

  def kata_create(manifest, files)
    id = singler.create(manifest, files)
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
